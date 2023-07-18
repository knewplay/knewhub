class PullGithubRepoJob
  include Sidekiq::Job

  def perform(name, owner)
    repository = Repository.find_by(name:, owner:)
    directory = Rails.root.join('repos', repository.owner, repository.name)
    if Dir.exist?(directory)
      Git.open(directory).pull
    else
      Git.clone(repository.git_url, directory, options: { branch: repository.branch })
    end
    description = get_description(repository.owner, repository.name, repository.token)
    repository.update(last_pull_at: DateTime.current, description:)
  end

  private

  def get_description(owner, name, token)
    client = Octokit::Client.new(access_token: token)
    repo = client.repository("#{owner}/#{name}")
    repo.description
  end
end
