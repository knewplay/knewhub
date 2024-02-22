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
    FileUtils.mkdir_p(new_directories.first)

    old_directories.each_with_index do |old_directory, i|
      FileUtils.mv(old_directory, new_directories[i])
    end
  end
end
