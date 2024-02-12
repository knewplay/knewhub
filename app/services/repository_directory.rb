# Finding or deleting a directory associated to a repository Record
class RepositoryDirectory
  def self.define(repository_id)
    repository = Repository.find(repository_id)
    directory = Rails.root.join('repos', repository.owner, repository.name)
    [repository, directory]
  end
end
