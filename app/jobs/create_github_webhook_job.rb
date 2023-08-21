class CreateGithubWebhookJob
  include Sidekiq::Job

  def perform(repository_id)
    repository = Repository.includes(:author).find(repository_id)
    client = Octokit::Client.new(access_token: repository.token)
    host_url = Rails.application.credentials.host_url
    webhook_secret = Rails.application.credentials.webhook_secret

    client.create_hook(
      "#{repository.author.github_username}/#{repository.name}",
      'web',
      { url: "https://#{host_url}/webhooks/github/#{repository.uuid}", content_type: 'json', secret: webhook_secret },
      { events: ['push'], active: true }
    )
  rescue Octokit::Unauthorized, Octokit::UnprocessableEntity => e
    Rails.logger.error "Failed to create GitHub webhook for repository ##{repository.name}. Message: #{e.message}"
  end
end
