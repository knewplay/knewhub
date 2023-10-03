class PullGithubRepoJob
  include Sidekiq::Job

  def perform(repository_id, build_id)
    repository, directory = RepositoryDirectory.define(repository_id)
    build = Build.find(build_id)
    step = step_for_action(build.action)

    Git.open(directory).pull
    repository.update(last_pull_at: DateTime.current)
    build.logs.create(content: 'Repository successfully pulled.', step:)

    build.finished_pulling_repo
  rescue Git::FailedError, ArgumentError => e
    build.logs.create(
      content: "Failed to pull repository. Message: #{e.message}",
      failure: true,
      step:
    )
  end

  def step_for_action(action)
    case action
    when 'update'
      1
    when 'rebuild'
      1
    end
  end
end
