module Webhooks
  class GithubController < ApplicationController
    skip_forgery_protection

    before_action :verify_event

    # rubocop:disable Metrics/MethodLength
    def create
      head :ok

      case request.headers['X-GitHub-Event']
      when 'push'
        push_event
      when 'installation'
        handle_installation_event
      when 'installation_target'
        installation_target_event
      when 'repository'
        repository_event
      end
    end
    # rubocop:enable Metrics/MethodLength

    private

    def verify_event
      secret = Rails.application.credentials.webhook_secret
      signature = "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, request.raw_post)}"
      return if ActiveSupport::SecurityUtils.secure_compare(signature, request.headers['X-Hub-Signature-256'])

      head :bad_request
    end

    def handle_installation_event
      if github_params[:action] == 'created'
        create_installation_event
      elsif github_params[:action] == 'deleted'
        delete_installation_event
      end
    end

    def github_params
      params[:github]
    end

    def repository_id
      github_params[:repository][:id]
    end

    def repository_name
      # [:changes] used in 'rename repository' event. It is the old name of the repository
      github_params[:changes] ? github_params[:changes][:repository][:name][:from] : github_params[:repository][:name]
    end

    def repository_owner_id
      github_params[:repository][:owner][:id].to_s
    end

    def repository_owner_name
      github_params[:repository][:owner][:name]
    end

    def github_installation_id
      github_params[:installation][:id].to_s
    end

    def github_installation_account_id
      if github_params[:installation][:account]
        github_params[:installation][:account][:id]
      else
        github_params[:account][:id]
      end
    end

    def github_installation_account_name
      if github_params[:installation][:account]
        github_params[:installation][:account][:login]
      else
        github_params[:account][:login]
      end
    end

    def find_repository
      repository = Repository.includes(:github_installation).find_by(
        name: repository_name,
        uid: repository_id,
        github_installation: { installation_id: github_installation_id }
      )
      repository_not_found_log if repository.nil?
      repository
    end

    def repository_not_found_log
      content = <<~MSG
        Could not find Repository with uid: #{repository_id} and name: #{repository_name} for Github Installation with installation_id: #{github_installation_id}.
      MSG
      logger.warn content
    end

    def find_github_installation
      github_installation = GithubInstallation.find_by(
        installation_id: github_installation_id,
        uid: github_installation_account_id
      )
      if github_installation.nil?
        logger.error "Could not find Github Installation with installation_id: #{github_installation_id} " \
                     "and uid: #{github_installation_account_id}."
      end
      github_installation
    end

    # 'push' event
    def push_event
      repository = find_repository
      return if repository.nil?

      build = Build.create(repository:, status: 'In progress', action: 'webhook_push')
      build.logs.create(content: "GitHub webhook 'push' received. Updating repository...")

      continue_push(repository, build)
    end

    def continue_push(repository, build)
      if repository.github_installation.uid == repository_owner_id
        description = github_params[:repository][:description]
        build.receive_webhook_push(repository_id, repository_name, repository_owner_name, description)
      else
        content = <<~MSG
          The ownership of the repository has changed.
          Please login with GitHub with the new repository owner's account to add the repository to Knewhub.
        MSG
        build.logs.create(content:, failure: true)
      end
    end

    # 'installation' event
    def create_installation_event
      requester_params = github_params[:requester]
      github_uid = requester_params ? requester_params[:id].to_s : github_params[:sender][:id].to_s
      author = Author.find_by(github_uid:)
      if author.nil?
        logger.error "Could not find Author with github_uid: #{github_uid}."
      else
        create_github_installation(author)
      end
    end

    def create_github_installation(author)
      author.github_installations.build(
        installation_id: github_installation_id,
        uid: github_installation_account_id,
        username: github_installation_account_name
      )
      author.save
    end

    def delete_installation_event
      github_installation = find_github_installation
      return if github_installation.nil?

      delete_github_installation(github_installation)
    end

    def delete_github_installation(github_installation)
      if github_installation.repositories.count.positive?
        AuthorMailer.with(github_installation:).github_installation_deleted.deliver_later
      end
      github_installation.destroy
    end

    # 'installation_target' event
    def installation_target_event
      return unless github_params[:action] == 'renamed'

      github_installation = find_github_installation
      return if github_installation.nil?

      old_github_installation_account_name = github_params[:changes][:login][:from]
      return if old_github_installation_account_name != github_installation.username

      rename_github_installation(github_installation)
    end

    def rename_github_installation(github_installation)
      RenameGithubInstallationUsernameJob.perform_async(
        github_installation.id,
        github_installation_account_name
      )
    end

    # 'repository' event
    def repository_event
      repository = find_repository
      return if repository.nil?

      repository_actions(repository)
    end

    def repository_actions(repository)
      if github_params[:action] == 'renamed'
        RenameRepoJob.perform_async(repository.id, github_params[:repository][:name])
      elsif github_params[:action] == 'deleted'
        AuthorMailer.with(repository:).repository_deleted.deliver_later
      end
    end
  end
end
