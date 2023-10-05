class CloneGithubRepoJob
  include Sidekiq::Job

  def perform(build_id)
    build = Build.find(build_id)
    repository, directory = RepositoryDirectory.define(build.repository.id)

    Git.clone(repository.git_url, directory, branch: repository.branch)
    repository.update(last_pull_at: DateTime.current)
    build.logs.create(content: 'Repository successfully cloned.')
    build.finished_cloning_or_pulling_repo
  rescue Git::FailedError => e
    build.logs.create(content: "Failed to clone repository. Message: #{e.message}", failure: true)
  end
end
