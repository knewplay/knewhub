# Returns the repository instance and its directory when given an `id`
class RepositoryDirectory
  def self.define(repository_id)
    repository = Repository.includes(:author).find(repository_id)
    directory = Rails.root.join('repos', repository.author.github_username, repository.name)
    [repository, directory]
  end
end
