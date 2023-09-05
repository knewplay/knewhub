class PullGithubRepoJob
  include Sidekiq::Job

  def perform(repository_id)
    repository, directory = RepositoryDirectory.define(repository_id)

    Git.open(directory).pull
    repository.update(last_pull_at: DateTime.current)
    repository.logs.create(content: 'Repository successfully pulled.')

    GetGithubDescriptionJob.perform_async(repository_id)
  rescue Git::FailedError => e
    repository.logs.create(content: "Failed to pull repository ##{repository.id}. Message: #{e.message}")
  end
end
