class CreateGithubWebhookJob < ApplicationJob
  rescue_from(Octokit::UnprocessableEntity) do |exception|
    p exception.message
  end

  def perform(repository)
    client = Octokit::Client.new(access_token: repository.token)
    host_url = Rails.application.credentials.host_url
    webhook_secret = Rails.application.credentials.webhook_secret

    client.create_hook(
      "#{repository.owner}/#{repository.name}",
      'web',
      { url: "https://#{host_url}/webhooks/github", content_type: 'json', secret: webhook_secret },
      { events: ['push'], active: true }
    )
  end
end
