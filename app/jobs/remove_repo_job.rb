class RemoveRepoJob
  include Sidekiq::Job

  def perform(github_username, name, hook_id, token, directory)
    remove_webhook(github_username, name, hook_id, token)
    delete_local_files(directory)
  end

  def remove_webhook(github_username, name, hook_id, token)
    client = Octokit::Client.new(access_token: token)
    client.remove_hook("#{github_username}/#{name}", hook_id)
  end

  def delete_local_files(directory)
    FileUtils.rm_r(directory) if Dir.exist?(directory)
  end
end
