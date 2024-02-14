class TestGithubWebhookJob
  include Sidekiq::Job

  def perform(build_id)
    build = Build.find(build_id)
    repository = Repository.includes(:github_installation).find(build.repository.id)
    github_client = repository.github_installation.github_client

    response = github_client.hook(repository.full_name, repository.hook_id)
    handle_response(build, response)
  end

  private

  def handle_response(build, response)
    case response.last_response.code
    when 200
      successful_test(build)
    when nil?
      content = <<~MSG
        Test of GitHub webhook failed. Message: Hook does not exist. Check GitHub repository settings, under Webhooks tab.
      MSG
      failed_test(build, content)
    else
      failed_test(build, "Test of GitHub webhook failed. Message: #{response.last_response.message}")
    end
  end

  def successful_test(build)
    build.logs.create(content: 'GitHub webhook successfully tested.')
    build.finished_testing_webhook
  end

  def failed_test(build, content)
    build.logs.create(content:, failure: true)
  end
end
