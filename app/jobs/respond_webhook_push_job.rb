class RespondWebhookPushJob
  include Sidekiq::Job

  def perform(build_id, uuid, webhook_name, webhook_owner, webhook_description)
    repository = Repository.find_by(uuid:)
    build = Build.find(build_id)
    if webhook_name != repository.name || webhook_owner != repository.author.github_username
      update_repository(repository, build, webhook_name, webhook_owner)
    else
      build.logs.create(content: 'No change to repository name or owner.')
    end
    directory = Rails.root.join('repos', repository.author.github_username, repository.name)
    pull_or_clone(repository, directory, build)
    repository.update(last_pull_at: DateTime.current, description: webhook_description)
  end

  private

  def pull_or_clone(repository, directory, build)
    if Dir.exist?(directory)
      response = Git.open(directory).pull
      build.logs.create(content: 'Repository successfully pulled.')
      CreateRepoIndexJob.perform_async(repository.id, build.id) unless response == 'Already up to date'
    else
      Git.clone(repository.git_url, directory, branch: repository.branch)
      build.logs.create(content: 'Repository successfully cloned.')
      CreateRepoIndexJob.perform_async(repository.id, build.id)
    end
  rescue Git::FailedError => e
    Rails.logger.error "Failed to clone or pull repository ##{repository.name}. Message: #{e.message}"
  end

  def update_repository(repository, build, webhook_name, webhook_owner)
    old_directory = Rails.root.join('repos', repository.author.github_username, repository.name)
    FileUtils.remove_dir(old_directory) if Dir.exist?(old_directory)
    repository.update(
      name: webhook_name,
      git_url: "https://#{repository.token}@github.com/#{webhook_owner}/#{webhook_name}.git"
    )
    repository.author.update(github_username: webhook_owner)
    build.logs.create(content: 'Repository name or owner successfully updated.')
  end
end
