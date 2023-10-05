class GetGithubDescriptionJob
  include Sidekiq::Job

  def perform(build_id)
    build = Build.find(build_id)
    repository = Repository.includes(:author).find(build.repository.id)

    client = Octokit::Client.new(access_token: repository.token)
    response = client.repository("#{repository.author.github_username}/#{repository.name}")
    repository.update(description: response.description)

    build.logs.create(content: 'Repository description successfully updated from GitHub.')
    build.finished_getting_repo_description
  rescue Octokit::Unauthorized, Octokit::UnprocessableEntity => e
    build.logs.create(
      content: "Failed to get description from GitHub. Message: #{e.message}",
      failure: true
    )
  end
end
