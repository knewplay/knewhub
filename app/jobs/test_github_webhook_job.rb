class TestGithubWebhookJob
  include Sidekiq::Job

  def perform(repository_id, build_id)
    repository = Repository.includes(:author).find(repository_id)
    build = Build.find(build_id)
    client = Octokit::Client.new(access_token: repository.token)

    response = client.hook("#{repository.author.github_username}/#{repository.name}", repository.hook_id)
    if response.last_response.code == 200
      build.logs.create(content: 'GitHub webhook successfully tested.')
      build.finished_testing_webhook
    elsif response.last_response.code.nil?
      content = <<~MSG
        Test of GitHub webhook failed. Message: Hook does not exist. Check GitHub repository settings, under Webhooks tab.
      MSG
      build.logs.create(content:, failure: true)
    else
      build.logs.create(
        content: "Test of GitHub webhook failed. Message: #{response.last_response.message}",
        failure: true
      )
    end
  end
end
