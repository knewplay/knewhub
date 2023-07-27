class CloneGithubRepoJob
  include Sidekiq::Job

  def perform(repository_id)
    repository = Repository.includes(:author).find(repository_id)
    directory = Rails.root.join('repos', repository.author.github_username, repository.name)
    Git.clone(repository.git_url, directory, options: { branch: repository.branch })
    repository.update(last_pull_at: DateTime.current, description: get_description(repository))
  end

  private

  def get_description(repository)
    client = Octokit::Client.new(access_token: repository.token)
    repo = client.repository("#{repository.author.github_username}/#{repository.name}")
    repo.description
  end
end
