class RespondWebhookPushJob
  include Sidekiq::Job

  def perform(build_id, uuid, webhook_name, webhook_owner, webhook_description)
    repository = Repository.find_by(uuid:)
    build = Build.find(build_id)
    check_repository_update_required(repository, build, webhook_name, webhook_owner)

    repository.update(description: webhook_description)
    build.logs.create(content: 'Repository description successfully updated from GitHub.')

    directory = Rails.root.join('repos', repository.author.github_username, repository.name)
    Dir.exist?(directory) ? build.finished_receiving_webhook('pull') : build.finished_receiving_webhook('clone')
  end

  private

  def check_repository_update_required(repository, build, webhook_name, webhook_owner)
    if webhook_name != repository.name || webhook_owner != repository.author.github_username
      update_repository(repository, build, webhook_name, webhook_owner)
    else
      build.logs.create(content: 'No change to repository name or owner.')
    end
  end

  def update_repository(repository, build, webhook_name, webhook_owner)
    old_directory = Rails.root.join('repos', repository.author.github_username, repository.name)
    FileUtils.rm_r(old_directory) if Dir.exist?(old_directory)
    repository.update(
      name: webhook_name,
      git_url: "https://#{repository.token}@github.com/#{webhook_owner}/#{webhook_name}.git"
    )
    repository.author.update(github_username: webhook_owner)
    build.logs.create(content: 'Repository name or owner successfully updated.')
  end
end
