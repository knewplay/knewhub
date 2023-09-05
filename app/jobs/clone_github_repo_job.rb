class CloneGithubRepoJob
  include Sidekiq::Job

  def perform(repository_id)
    repository, directory = RepositoryDirectory.define(repository_id)

    Git.clone(repository.git_url, directory, branch: repository.branch)
    repository.update(last_pull_at: DateTime.current)
    repository.logs.create(content: 'Repository successfully cloned.')

    GetGithubDescriptionJob.perform_async(repository_id)
  rescue Git::FailedError => e
    repository.logs.create(content: "Failed to clone repository ##{repository.id}. Message: #{e.message}")
  end
end
