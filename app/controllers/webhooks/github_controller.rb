class Webhooks::GithubController < ApplicationController
  skip_forgery_protection

  before_action :verify_event

  def create
    head :ok

    uuid = params[:uuid]
    repository = Repository.find_by!(uuid:)

    case request.headers['X-GitHub-Event']
    when 'push'
      build = Build.create(repository:, status: 'In progress', action: 'webhook_push')
      build.logs.create(content: "GitHub webhook 'push' received. Updating repository...")

      name = params[:repository][:name]
      owner_name = params[:repository][:owner][:name]
      owner_id = params[:repository][:owner][:id].to_s
      description = params[:repository][:description]

      if repository.author.github_uid != owner_id
        flash.now[:notice] = "The ownership of repository #{name} has changed."\
                             "Please login with GitHub as #{owner_name} and add repository to Knewhub."
      else
        RespondWebhookPushJob.perform_async(build.id, uuid, name, owner_name, description)
      end
    end
  end

  private

  def verify_event
    secret = Rails.application.credentials.webhook_secret
    signature = "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, request.raw_post)}"
    unless ActiveSupport::SecurityUtils.secure_compare(signature, request.headers['X-Hub-Signature-256'])
      head :bad_request
    end
  end
end
