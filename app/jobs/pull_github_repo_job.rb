class PullGithubRepoJob
  include Sidekiq::Job

  def perform(repository_id, build_id)
    repository, directory = RepositoryDirectory.define(repository_id)
    build = Build.find(build_id)

    Git.open(directory).pull
    repository.update(last_pull_at: DateTime.current)
    build.logs.create(content: 'Repository successfully pulled.')

    GetGithubDescriptionJob.perform_async(repository_id, build_id)
  rescue Git::FailedError => e
    build.logs.create(content: "Failed to pull repository ##{repository.id}. Message: #{e.message}")
  end
end
