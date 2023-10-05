class CreateGithubWebhookJob
  include Sidekiq::Job

  def perform(build_id)
    build = Build.find(build_id)
    repository = Repository.includes(:author).find(build.repository.id)

    client = Octokit::Client.new(access_token: repository.token)
    host_url = Rails.application.credentials.host_url
    webhook_secret = Rails.application.credentials.webhook_secret

    response = create_hook(repository, client, host_url, webhook_secret)
    repository.update(hook_id: response.id)
    build.logs.create(content: 'GitHub webhook successfully created. Now testing...')
    build.finished_creating_webhook
  rescue Octokit::Unauthorized, Octokit::UnprocessableEntity => e
    build.logs.create(
      content: "Failed to create GitHub webhook. Message: #{e.message}",
      failure: true
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
end
