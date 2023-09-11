class Author < ApplicationRecord
  belongs_to :user, optional: true
  has_many :repositories, dependent: :destroy

  before_create :set_name

  validates :github_uid, presence: true, uniqueness: true
  validates :github_username, presence: true, uniqueness: true
  validates :name,
            format: { with: /\A[a-zA-Z0-9-]{0,39}\z/, message: 'can only contain alphanumeric characters and dashes' },
            length: { maximum: 39 },
            on: :update

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

  private

  def set_name
    self.name = github_username
  end
end
