class GetGithubDescriptionJob
  include Sidekiq::Job

  def perform(repository_id)
    repository = Repository.includes(:author).find(repository_id)
    client = Octokit::Client.new(access_token: repository.token)
    response = client.repository("#{repository.author.github_username}/#{repository.name}")
    repository.update(description: response.description)
  end
end
