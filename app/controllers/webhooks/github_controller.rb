module Webhooks
  class GithubController < ApplicationController
    skip_forgery_protection

    before_action :verify_event

    def create
      head :ok

      case request.headers['X-GitHub-Event']
      when 'push'
        push_event
      when 'installation'
        handle_installation_event
      when 'repository'
        repository_event
      end
    end

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

    # 'push' event
    def push_event
      repository_params = params[:repository]
      repository = Repository.find_by!(uid: repository_params[:id].to_i)
      build = Build.create(repository:, status: 'In progress', action: 'webhook_push')
      build.logs.create(content: "GitHub webhook 'push' received. Updating repository...")

      create_actions(repository, build, repository_params)
    end

    def create_actions(repository, build, repository_params)
      owner_id = repository_params[:owner][:id].to_s
      if repository.github_installation.uid == owner_id
        repository_owner_unchanged(repository_params, build)
      else
        repository_owner_changed(build)
      end
    end

    def repository_owner_changed(build)
      content = <<~MSG
        The ownership of the repository has changed.
        Please login with GitHub with the new repository owner's account to add the repository to Knewhub.
      MSG
      build.logs.create(content:, failure: true)
    end

    def repository_owner_unchanged(repository_params, build)
      uid = repository_params[:id].to_i
      name = repository_params[:name]
      owner_name = repository_params[:owner][:name]
      description = repository_params[:description]
      build.receive_webhook_push(uid, name, owner_name, description)
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
      installation_params = github_params[:installation]

      author.github_installations.build(
        installation_id: installation_params[:id].to_s,
        uid: installation_params[:account][:id].to_s,
        username: installation_params[:account][:login]
      )
      author.save
    end

    def delete_installation_event
      installation_params = github_params[:installation]
      installation_id = installation_params[:id].to_s
      uid = installation_params[:account][:id].to_s
      github_installation = GithubInstallation.find_by(installation_id:, uid:)

      if github_installation.nil?
        logger.error "Could not find Github Installation with installation_id: #{installation_id} and uid: #{uid}."
      else
        delete_github_installation(github_installation)
      end
    end

    def delete_github_installation(github_installation)
      if github_installation.repositories.count.positive?
        AuthorMailer.with(github_installation:).github_installation_deleted.deliver_later
      end
      github_installation.destroy
    end

    # 'repository' event
    def repository_event
      installation_id = github_params[:installation][:id].to_s
      repository_uid = github_params[:repository][:id]
      repository_name = if github_params[:changes]
                          github_params[:changes][:repository][:name][:from]
                        else
                          github_params[:repository][:name]
                        end
      repository = Repository.includes(:github_installation).find_by(name: repository_name, uid: repository_uid,
                                                                     github_installation: { installation_id: })
      repository_actions(repository, repository_uid, repository_name, installation_id)
    end

    def repository_actions(repository, repository_uid, repository_name, installation_id)
      if repository.nil?
        repository_not_found_log(repository_uid, repository_name, installation_id)
      elsif github_params[:action] == 'renamed'
        rename_repository_and_move_directory(repository)
      elsif github_params[:action] == 'deleted'
        AuthorMailer.with(repository:).repository_deleted.deliver_later
      end
    end

    def repository_not_found_log(repository_uid, repository_name, installation_id)
      content = <<~MSG
        Could not find Repository with uid: #{repository_uid} and name: #{repository_name} for Github Installation with installation_id: #{installation_id}.
      MSG
      logger.warn content
    end

    def rename_repository_and_move_directory(repository)
      new_name = github_params[:repository][:name]
      old_directory = repository.storage_path
      repository.update(name: new_name)
      new_directory = repository.storage_path
      FileUtils.mv(old_directory, new_directory)
    end
  end
end
