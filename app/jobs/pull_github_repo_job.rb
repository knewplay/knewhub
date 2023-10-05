class PullGithubRepoJob
  include Sidekiq::Job

  def perform(build_id)
    build = Build.find(build_id)
    repository, directory = RepositoryDirectory.define(build.repository.id)

    Git.open(directory).pull
    repository.update(last_pull_at: DateTime.current)
    build.logs.create(content: 'Repository successfully pulled.')

    build.finished_cloning_or_pulling_repo
  rescue Git::FailedError, ArgumentError => e
    build.logs.create(
      content: "Failed to pull repository. Message: #{e.message}",
      failure: true
    )
  end
end
