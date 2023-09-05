class CreateGithubWebhookJob
  include Sidekiq::Job

  def perform(repository_id)
    repository = Repository.includes(:author).find(repository_id)
    client = Octokit::Client.new(access_token: repository.token)
    host_url = Rails.application.credentials.host_url
    webhook_secret = Rails.application.credentials.webhook_secret

    response = create_hook(repository, client, host_url, webhook_secret)
    test_hook(client, repository, response.id)
  rescue Octokit::Unauthorized, Octokit::UnprocessableEntity => e
    repository.logs.create(
      content: "Failed to create GitHub webhook for repository ##{repository.id}. Message: #{e.message}"
    )
  end

  def create_hook(repository, client, host_url, webhook_secret)
    client.create_hook(
      "#{repository.author.github_username}/#{repository.name}",
      'web',
      { url: "https://#{host_url}/webhooks/github/#{repository.uuid}", content_type: 'json', secret: webhook_secret },
      { events: ['push'], active: true }
    )
  end

  def test_hook(client, repository, hook_id)
    response = client.test_hook("#{repository.author.github_username}/#{repository.name}", hook_id)
    if response == true
      repository.logs.create(content: 'GitHub webhook successfully created.')
    else
      repository.logs.create(
        content: "Failed to create GitHub webhook for repository ##{repository.id}. Message: #{response.message}"
      )
    end
  end
end
