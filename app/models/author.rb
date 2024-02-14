class Author < ApplicationRecord
  belongs_to :user, optional: true
  has_many :github_installations, dependent: :destroy
  has_many :repositories, through: :github_installations

  before_create :set_name

  validates :github_uid, presence: true, uniqueness: true
  validates :github_username, presence: true, uniqueness: true
  validates :name,
            format: { with: /\A[a-zA-Z0-9-]{0,39}\z/, message: 'can only contain alphanumeric characters and dashes' },
            length: { maximum: 39 },
            on: :update

  def list_github_repositories(result = [])
    github_installations.each do |install|
      result.push(*install.list_github_repositories)
    end
    result
  end

  def repositories_available_for_addition(result = [])
    github_installations.each do |install|
      result.push(*install.repositories_available_for_addition)
    end
    result
  end

  private

  def set_name
    self.name = github_username
  end
end
