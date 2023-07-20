class Repository < ApplicationRecord
  before_create :set_git_url, :set_branch

  validates :owner,
            presence: true,
            format: { with: /\A[a-z\d-]{0,38}\z/, message: 'must follow GitHub username restrictions' }
  validates :name,
            presence: true,
            format: { with: /\A[\.\w-]{0,100}\z/, message: 'must follow GitHub repository name restrictions' }
  validates :token,
            presence: true,
            format: { with: /\A(github_pat|ghp)\w+\z/, message: 'must start with "github_pat" or "ghp"' }
  validates :branch,
            format: { with: /\A[\.\/\w-]{0,100}\z/, message: 'must follow GitHub branch name restrictions' }

  private

  def set_git_url
    self.git_url = "https://#{token}@github.com/#{owner}/#{name}.git"
  end

  def set_branch
    self.branch = if branch.blank?
                    'main'
                  else
                    branch
                  end
  end
end