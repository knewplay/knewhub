class TestGithubWebhookJob
  include Sidekiq::Job

  def perform(repository_id, build_id, hook_id)
    repository = Repository.includes(:author).find(repository_id)
    build = Build.find(build_id)
    client = Octokit::Client.new(access_token: repository.token)

    response = client.hook("#{repository.author.github_username}/#{repository.name}", hook_id)
    if response.last_response.code == 200
      build.logs.create(content: 'GitHub webhook successfully tested.', step: 2)
    else
      build.logs.create(
        content: "Test of GitHub webhook failed. Message: #{response.last_response.message}",
        failure: true,
        step: 2
      )
    end
  end
end
