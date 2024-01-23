class Repository < ApplicationRecord
  belongs_to :author
  has_many :builds, dependent: :destroy
  has_many :questions, dependent: :destroy

  before_save :set_git_url
  before_create :set_branch, :generate_uuid

  validates :name,
            presence: true,
            format: { with: /\A[.\w-]{0,100}\z/, message: 'must follow GitHub repository name restrictions' }
  validates :name, uniqueness: { scope: :author_id }
  validates :token,
            presence: true,
            format: { with: /\A(github_pat|ghp)\w+\z/, message: 'must start with "github_pat" or "ghp"' }
  validates :branch,
            format: { with: %r{\A[./\w-]{0,100}\z}, message: 'must follow GitHub branch name restrictions' }
  validates :title, presence: true
  attribute :banned, :boolean, default: false

  def last_build_created_at
    builds.last&.created_at
  end

  def last_build_status
    builds.last&.status
  end

  def visible?
    banned == false && last_build_status == 'Complete'
  end

  private

  def set_git_url
    self.git_url = "https://#{token}@github.com/#{author.github_username}/#{name}.git"
  end

  def set_branch
    self.branch = (branch.presence || 'main')
  end

  def generate_uuid
    self.uuid = SecureRandom.uuid if uuid.nil?
  end
end
