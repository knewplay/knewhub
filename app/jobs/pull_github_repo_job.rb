class PullGithubRepoJob
  include Sidekiq::Job

  def perform(repository_id, build_id)
    repository, directory = RepositoryDirectory.define(repository_id)
    build = Build.find(build_id)
    step = step_for_action(build.action)

    response = Git.open(directory).pull
    repository.update(last_pull_at: DateTime.current)
    build.logs.create(content: 'Repository successfully pulled.', step:)

    GetGithubDescriptionJob.perform_async(repository_id, build_id)
    ParseQuestionsJob.perform_async(repository.id, build.id)
    if response == 'Already up to date'
      build.logs.create(content: 'index.md file exists for this repository.', step: 4)
    else
      CreateRepoIndexJob.perform_async(repository.id, build.id)
    end
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
