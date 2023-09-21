class GetGithubDescriptionJob
  include Sidekiq::Job

  def perform(repository_id, build_id)
    repository = Repository.includes(:author).find(repository_id)
    build = Build.find(build_id)
    client = Octokit::Client.new(access_token: repository.token)
    response = client.repository("#{repository.author.github_username}/#{repository.name}")
    repository.update(description: response.description)

    build.logs.create(content: 'Repository description successfully updated from GitHub.')
  rescue Octokit::Unauthorized, Octokit::UnprocessableEntity => e
    build.logs.create(
      content: "Failed to get description from GitHub. Message: #{e.message}",
      failure: true
    )
  end
end
