class RemoveRepoJob
  include Sidekiq::Job

  def perform(repository_id)
    repository, directory = RepositoryDirectory.define(repository_id)
    remove_webhook(repository)
    delete_local_files(directory)
    repository.destroy
  end

  def remove_webhook(repository)
    client = Octokit::Client.new(access_token: repository.token)
    client.remove_hook("#{repository.author.github_username}/#{repository.name}", repository.hook_id)
  end

  def delete_local_files(directory)
    FileUtils.rm_r(directory) if Dir.exist?(directory)
  end
end
