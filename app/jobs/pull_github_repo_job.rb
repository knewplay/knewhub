class PullGithubRepoJob
  include Sidekiq::Job

  def perform(repository_id)
    repository, directory = RepositoryDirectory.define(repository_id)

    Git.open(directory).pull
    repository.update(last_pull_at: DateTime.current)

    GetGithubDescriptionJob.perform_async(repository_id)
  end
end
