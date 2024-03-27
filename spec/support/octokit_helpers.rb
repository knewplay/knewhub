# Octokit is used to perform the git clone and git pull actions
# These helpers are used to mock git actions in order to speed up the test suite where possible
module OctokitHelpers
  # Pretend to clone a repository by creating a new directory and updating `last_pull_at`
  def git_clone(repository)
    destination_directory = repository.storage_path
    source_directory = Rails.root.join('spec/fixtures/systems/git_clone')
    FileUtils.mkdir_p(destination_directory)
    FileUtils.copy_entry(source_directory, destination_directory)

    repository.update(last_pull_at: DateTime.current)
  end

  # Pretend to pull a repository by updating the `last_pull_at`
  def git_pull(repository)
    repository.update(last_pull_at: DateTime.current)
  end
end
