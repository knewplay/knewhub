class GetGithubDescriptionJob
  include Sidekiq::Job

  def perform(repository_id)
    repository = Repository.includes(:author).find(repository_id)
    client = Octokit::Client.new(access_token: repository.token)
    response = client.repository("#{repository.author.github_username}/#{repository.name}")
    repository.update(description: response.description)

    repository.logs.create(content: 'Repository description successfully updated from GitHub.')
  rescue Octokit::Unauthorized, Octokit::UnprocessableEntity => e
    repository.logs.create(content: "Failed to get description for repository ##{repository.id}. Message: #{e.message}")
  end
end
