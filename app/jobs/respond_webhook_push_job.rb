class RespondWebhookPushJob
  include Sidekiq::Job

  def perform(uuid, webhook_name, webhook_owner, webhook_description)
    repository = Repository.find_by(uuid:)
    if webhook_name != repository.name || webhook_owner != repository.author.github_username
      update_repository(repository, webhook_name, webhook_owner)
    end
    directory = Rails.root.join('repos', repository.author.github_username, repository.name)
    pull_or_clone(repository, directory)
    repository.update(last_pull_at: DateTime.current, description: webhook_description)
  end

  private

  def pull_or_clone(repository, directory)
    if Dir.exist?(directory)
      Git.open(directory).pull
    else
      Git.clone(repository.git_url, directory, options: { branch: repository.branch })
    end
  end

  def update_repository(repository, webhook_name, webhook_owner)
    old_directory = Rails.root.join('repos', repository.author.github_username, repository.name)
    FileUtils.remove_dir(old_directory) if Dir.exist?(old_directory)
    repository.update(
      name: webhook_name,
      git_url: "https://#{repository.token}@github.com/#{webhook_owner}/#{webhook_name}.git"
    )
    repository.author.update(github_username: webhook_owner)
  end
end
