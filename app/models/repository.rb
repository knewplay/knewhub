class Repository < ApplicationRecord
  before_validation :set_git_url

  validates :owner,
            presence: true,
            format: { with: /\A[a-z\d-]{0,38}\z/, message: 'must follow GitHub username restrictions' }
  validates :name,
            presence: true,
            format: { with: /\A[\.\w-]{0,100}\z/, message: 'must follow GitHub repository name restrictions' }
  validates :token,
            allow_blank: true,
            format: { with: /\A(github_pat|ghp)\w+\z/, message: 'must start with "github_pat" or "ghp"' }

  private

  def set_git_url
    self.git_url = if token.blank?
                     "https://github.com/#{owner}/#{name}.git"
                   else
                     "https://#{token}@github.com/#{owner}/#{name}.git"
                   end
  end
end
