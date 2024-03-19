module OctokitHelpers
  def git_clone(repository)
    destination_directory = repository.storage_path
    source_directory = Rails.root.join('spec/fixtures/systems/git_clone')
    FileUtils.mkdir_p(destination_directory)
    FileUtils.copy_entry(source_directory, destination_directory)

    repository.update(last_pull_at: DateTime.current)
  end

  def git_pull(repository)
    repository.update(last_pull_at: DateTime.current)
  end
end
