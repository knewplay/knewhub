class Author < ApplicationRecord
  has_many :repositories, dependent: :destroy

  validates :github_uid, presence: true, uniqueness: true
  validates :github_username, presence: true, uniqueness: true

  def self.from_omniauth(access_token)
    github_uid = access_token.uid
    data = access_token.info
    github_username = data['nickname']

    author = Author.find_by(github_uid:)
    author ||= Author.create(github_uid:, github_username:)

    if author.github_username != github_username
      author.repositories.each do |repository|
        RepositoryDirectory.update_author(repository.id, github_username)
      end
      author.update(github_username:)
    end

    author
  end
end
