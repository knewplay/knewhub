module Webhooks
  class GithubController < ApplicationController
    skip_forgery_protection

    before_action :verify_event

    def create
      head :ok
      return unless request.headers['X-GitHub-Event'] == 'push'

      repository = Repository.find_by!(uuid: params[:uuid])
      build = Build.create(repository:, status: 'In progress', action: 'webhook_push')
      build.logs.create(content: "GitHub webhook 'push' received. Updating repository...")

      create_actions(repository, build, params)
    end

    private

    def create_actions(repository, build, params)
      owner_id = params[:repository][:owner][:id].to_s
      if repository.author.github_uid == owner_id
        repository_owner_unchanged(params, build)
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

    def repository_owner_unchanged(params, build)
      uuid = params[:uuid]
      name = params[:repository][:name]
      owner_name = params[:repository][:owner][:name]
      description = params[:repository][:description]
      build.receive_webhook_push(uuid, name, owner_name, description)
    end

    def verify_event
      secret = Rails.application.credentials.webhook_secret
      signature = "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, request.raw_post)}"
      return if ActiveSupport::SecurityUtils.secure_compare(signature, request.headers['X-Hub-Signature-256'])

      head :bad_request
    end
  end
end
