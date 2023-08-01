class CloneGithubRepoJob
  include Sidekiq::Job

  def perform(repository_id)
    repository = Repository.includes(:author).find(repository_id)
    directory = Rails.root.join('repos', repository.author.github_username, repository.name)
    Git.clone(repository.git_url, directory, options: { branch: repository.branch })
    repository.update(last_pull_at: DateTime.current)

    GetGithubDescriptionJob.perform_async(repository_id)
  end
end
