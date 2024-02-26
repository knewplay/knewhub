class RenameRepoJob
  include Sidekiq::Job

  def perform(repository_id, new_name)
    repository, old_directory = RepositoryDirectory.define(repository_id)
    repository.update(name: new_name)
    new_directory = repository.storage_path
    FileUtils.mv(old_directory, new_directory)
  end
end
