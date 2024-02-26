class RenameGithubInstallationUsernameJob
  include Sidekiq::Job

  def perform(github_installation_id, new_username)
    github_installation = GithubInstallation.find(github_installation_id)
    old_directories = github_installation.list_repository_directories
    github_installation.update(username: new_username)

    return if old_directories.empty?

    move_directories(github_installation, old_directories)
  end

  private

  def move_directories(github_installation, old_directories)
    new_directories = github_installation.list_repository_directories
    parent_directory = Rails.root.join(
      "repos/#{github_installation.author.github_username}/#{github_installation.username}"
    )
    FileUtils.mkdir_p(parent_directory)

    old_directories.each_with_index do |old_directory, i|
      FileUtils.mv(old_directory, new_directories[i])
    end
  end
end
