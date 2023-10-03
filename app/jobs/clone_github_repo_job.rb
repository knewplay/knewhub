class CloneGithubRepoJob
  include Sidekiq::Job

  def perform(repository_id, build_id)
    repository, directory = RepositoryDirectory.define(repository_id)
    build = Build.find(build_id)
    step = step_for_action(build.action)

    Git.clone(repository.git_url, directory, branch: repository.branch)
    repository.update(last_pull_at: DateTime.current)
    build.logs.create(content: 'Repository successfully cloned.', step:)

    GetGithubDescriptionJob.perform_async(repository_id, build_id)
    ParseQuestionsJob.perform_async(repository_id, build_id)
    CreateRepoIndexJob.perform_async(repository_id, build_id)
  rescue Git::FailedError => e
    build.logs.create(content: "Failed to clone repository. Message: #{e.message}", failure: true, step:)
  end

  def step_for_action(action)
    case action
    when 'create'
      3
    when 'update'
      1
    end
  end
end
