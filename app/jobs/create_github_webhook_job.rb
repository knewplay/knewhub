class CreateGithubWebhookJob
  include Sidekiq::Job

  rescue_from(Octokit::UnprocessableEntity) do |exception|
    p exception.message
  end

  def perform(token, owner, name)
    client = Octokit::Client.new(access_token: token)
    host_url = Rails.application.credentials.host_url
    webhook_secret = Rails.application.credentials.webhook_secret

    client.create_hook(
      "#{owner}/#{name}",
      'web',
      { url: "https://#{host_url}/webhooks/github", content_type: 'json', secret: webhook_secret },
      { events: ['push'], active: true }
    )
  end
end
