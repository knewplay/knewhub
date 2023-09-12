class CloneGithubRepoJob
  include Sidekiq::Job

  def perform(repository_id, build_id)
    repository, directory = RepositoryDirectory.define(repository_id)
    build = Build.find(build_id)

    Git.clone(repository.git_url, directory, branch: repository.branch)
    repository.update(last_pull_at: DateTime.current)
    build.logs.create(content: 'Repository successfully cloned.')

    GetGithubDescriptionJob.perform_async(repository_id, build_id)
    CreateRepoIndexJob.perform_async(repository_id, build_id)
  rescue Git::FailedError => e
    build.logs.create(content: "Failed to clone repository ##{repository.id}. Message: #{e.message}", failure: true)
  end
end
