class CreateGithubWebhookJob
  include Sidekiq::Job

  def perform(build_id)
    build = Build.find(build_id)
    repository = Repository.includes(:github_installation).find(build.repository.id)

    response = create_hook(repository)
    repository.update(hook_id: response.id)

    build.logs.create(content: 'GitHub webhook successfully created. Now testing...')
    build.finished_creating_webhook
  rescue Octokit::Unauthorized, Octokit::UnprocessableEntity, Octokit::Forbidden => e
    build.logs.create(content: "Failed to create GitHub webhook. Message: #{e.message}", failure: true)
  end

  def create_hook(repository)
    github_client = repository.github_installation.github_client
    host_url = ENV.fetch('WEB_URL', Rails.application.credentials.host_url)
    webhook_secret = Rails.application.credentials.webhook_secret

    github_client.create_hook(
      repository.full_name,
      'web',
      { url: "#{host_url}/webhooks/github/#{repository.uuid}", content_type: 'json', secret: webhook_secret },
      { events: ['push'], active: true }
    )
  end
end
