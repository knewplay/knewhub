class Author < ApplicationRecord
  validates :github_uid, presence: true, uniqueness: true
  validates :github_username, presence: true, uniqueness: true

  def self.from_omniauth(access_token)
    github_uid = access_token.uid
    data = access_token.info
    github_username = data['nickname']

    Author.find_or_create_by(github_username:, github_uid:)
  end
end
