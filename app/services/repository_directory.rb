# Finding the directory associated with a repository
class RepositoryDirectory
  def self.define(repository_id)
    repository = Repository.find(repository_id)
    directory = repository.storage_path
    [repository, directory]
  end
end
