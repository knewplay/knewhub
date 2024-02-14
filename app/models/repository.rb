class Repository < ApplicationRecord
  belongs_to :github_installation
  has_many :builds, dependent: :destroy
  has_many :questions, dependent: :destroy

  before_save :set_branch
  before_create :generate_uuid

  validates :name,
            presence: true,
            format: { with: /\A[.\w-]{0,100}\z/, message: 'must follow GitHub repository name restrictions' }
  validates :name, uniqueness: { scope: :github_installation_id }
  validates :branch,
            format: { with: %r{\A[./\w-]{0,100}\z}, message: 'must follow GitHub branch name restrictions' }
  validates :title, presence: true
  attribute :banned, :boolean, default: false

  delegate :author, to: :github_installation

  def owner
    github_installation.username
  end

  def git_url
    "https://x-access-token:#{github_installation.access_token}@github.com/#{owner}/#{name}.git"
  end

  def last_build_created_at
    builds.last&.created_at
  end

  def last_build_status
    builds.last&.status
  end

  def visible?
    banned == false && last_build_status == 'Complete'
  end

  def full_name
    "#{owner}/#{name}"
  end

  private

  def set_branch
    self.branch = (branch.presence || 'main')
  end

  def generate_uuid
    self.uuid = SecureRandom.uuid if uuid.nil?
  end
end
