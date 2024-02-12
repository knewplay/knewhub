class RemoveRepoJob
  include Sidekiq::Job

  def perform(author_id, full_name, hook_id)
    github_client = Author.find(author_id).github_client
    directory = Rails.root.join('repos', full_name)

    remove_webhook(github_client, full_name, hook_id)
    delete_local_files(directory)
  end

  def remove_webhook(github_client, full_name, hook_id)
    github_client.remove_hook(full_name, hook_id)
  end

  def delete_local_files(directory)
    FileUtils.rm_r(directory) if Dir.exist?(directory)
  end
end
