class GithubInstallation < ApplicationRecord
  belongs_to :author
  has_many :repositories, dependent: :nullify

  validates :installation_id, presence: true

  def access_token
    Github.new.access_token(installation_id)
  end

  def github_client
    Octokit::Client.new(access_token:, per_page: 100)
  end

  def list_github_repositories(result = [])
    response = github_client.list_app_installation_repositories({ per_page: 100 })
    repositories = response[:repositories]
    repositories.each do |repository|
      result << { full_name: repository[:full_name], uid: repository[:id] }
    end
    result
  end

  def already_added_repositories
    repositories.map(&:uid)
  end

  def repositories_available_for_addition
    list_github_repositories.reject do |repository|
      already_added_repositories.include?(repository[:uid])
    end
  end

  def list_repository_directories(directories = [])
    repositories.each do |repository|
      directories << repository.storage_path
    end
    directories
  end
end
