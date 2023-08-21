class CloneGithubRepoJob
  include Sidekiq::Job

  def perform(repository_id)
    repository, directory = RepositoryDirectory.define(repository_id)
    FileUtils.remove_dir(directory) if Dir.exist?(directory)

    Git.clone(repository.git_url, directory, branch: repository.branch)
    repository.update(last_pull_at: DateTime.current)

    GetGithubDescriptionJob.perform_async(repository_id)
  rescue Git::FailedError => e
    Rails.logger.error "Failed to clone repository ##{repository.name}. Message: #{e.message}"
  end
end
