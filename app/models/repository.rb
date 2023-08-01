class Repository < ApplicationRecord
  belongs_to :author

  before_create :set_branch, :generate_uuid
  before_save :set_git_url

  validates :name,
            presence: true,
            format: { with: /\A[\.\w-]{0,100}\z/, message: 'must follow GitHub repository name restrictions' }
  validates :token,
            presence: true,
            format: { with: /\A(github_pat|ghp)\w+\z/, message: 'must start with "github_pat" or "ghp"' }
  validates :branch,
            format: { with: /\A[\.\/\w-]{0,100}\z/, message: 'must follow GitHub branch name restrictions' }
  validates :title, presence: true

  private

  def set_git_url
    self.git_url = "https://#{token}@github.com/#{author.github_username}/#{name}.git"
  end

  def set_branch
    self.branch = if branch.blank?
                    'main'
                  else
                    branch
                  end
  end

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end
end
