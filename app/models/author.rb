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
  validates :installation_id, presence: true

  def access_token
    Github.new.access_token(installation_id)
  end

  def github_client
    Octokit::Client.new(access_token:)
  end

  def list_repositories
    github_client.list_app_installation_repositories
  end

  private

  def set_name
    self.name = github_username
  end
end
