class CreateGithubWebhookJob
  include Sidekiq::Job

  def perform(uuid, name, owner, token)
    client = Octokit::Client.new(access_token: token)
    host_url = Rails.application.credentials.host_url
    webhook_secret = Rails.application.credentials.webhook_secret

    client.create_hook(
      "#{owner}/#{name}",
      'web',
      { url: "https://#{host_url}/webhooks/github/#{uuid}", content_type: 'json', secret: webhook_secret },
      { events: ['push'], active: true }
    )
  rescue Octokit::UnprocessableEntity => e
    p e.message
  end
end
