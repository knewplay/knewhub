class GithubInstallation < ApplicationRecord
  belongs_to :author
  has_many :repositories, dependent: :destroy

  validates :installation_id, presence: true

  def access_token
    Github.new.access_token(installation_id)
  end

  def github_client
    Octokit::Client.new(access_token:)
  end

  def list_github_repositories
    repositories = github_client.list_app_installation_repositories['repositories']
    repositories.pluck(:full_name)
  end

  def repositories_available_for_addition
    github_repositories = list_github_repositories
    already_added_repositories = repositories.map(&:full_name)
    github_repositories - already_added_repositories
  end
end
