# Finding or deleting a directory associated to a repository Record
class RepositoryDirectory
  def self.define(repository_id)
    repository = Repository.includes(:author).find(repository_id)
    directory = Rails.root.join('repos', repository.author.github_username, repository.name)
    [repository, directory]
  end

  def self.update_author(repository_id, author)
    repository, old_directory = define(repository_id)
    new_directory = Rails.root.join('repos', author, repository.name)
    FileUtils.mkdir_p(new_directory)
    FileUtils.remove_dir(old_directory)
  end
end
