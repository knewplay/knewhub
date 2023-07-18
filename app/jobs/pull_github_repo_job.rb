class PullGithubRepoJob < ApplicationJob
  def perform(repository)
    directory = Rails.root.join('repos', repository.owner, repository.name)
    if Dir.exist?(directory)
      Git.open(directory).pull
    else
      Git.clone(repository.git_url, directory, options: { branch: repository.branch })
    end
    description = get_description(repository.owner, repository.name, repository.token)
    update_repository(repository.id, description)
  end

  private

  def update_repository(repository_id, description)
    repository = Repository.find(repository_id)
    repository.update(last_pull_at: DateTime.current, description:)
  end

  def get_description(owner, name, token)
    client = Octokit::Client.new(access_token: token)
    repo = client.repository("#{owner}/#{name}")
    repo.description
  end
end
