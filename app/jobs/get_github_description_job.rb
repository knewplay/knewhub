class GetGithubDescriptionJob
  include Sidekiq::Job

  def perform(build_id)
    build = Build.find(build_id)
    repository = Repository.includes(:author).find(build.repository.id)

    response = get_description(repository)
    repository.update(description: response.description)

    build.logs.create(content: 'Repository description successfully updated from GitHub.')
    build.finished_getting_repo_description
  rescue Octokit::Unauthorized, Octokit::UnprocessableEntity => e
    build.logs.create(content: "Failed to get description from GitHub. Message: #{e.message}", failure: true)
  end

  def get_description(repository)
    client = Octokit::Client.new(access_token: repository.token)
    client.repository("#{repository.author.github_username}/#{repository.name}")
  end
end
