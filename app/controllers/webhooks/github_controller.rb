module Webhooks
  class GithubController < ApplicationController
    skip_forgery_protection

    before_action :verify_event

    def create
      head :ok

      if request.headers['X-GitHub-Event'] == 'push'
        push_event
      end
    end

    private

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

    def verify_event
      secret = Rails.application.credentials.webhook_secret
      signature = "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, request.raw_post)}"
      return if ActiveSupport::SecurityUtils.secure_compare(signature, request.headers['X-Hub-Signature-256'])

      head :bad_request
    end
  end
end
