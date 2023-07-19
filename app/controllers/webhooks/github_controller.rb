class Webhooks::GithubController < ApplicationController
  skip_forgery_protection

  before_action :verify_event

  def create
    head :ok

    case request.headers['X-GitHub-Event']
    when 'ping'
      flash.now[:notice] = 'Webhook successfully created.'
    when 'push'
      name = params[:repository][:name]
      owner = params[:repository][:owner][:name]
      PullGithubRepoJob.perform_async(name, owner)
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
