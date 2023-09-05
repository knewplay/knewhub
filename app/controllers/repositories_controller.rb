class RepositoriesController < ApplicationController
  before_action :require_author_or_admin_authentication, only: [:update]
  before_action :require_administrator_authentication, only: [:toggle_banned_status]
  before_action :set_repository

  def update
    build = Build.create(repository: @repository, status: 'In progress')
    PullGithubRepoJob.perform_async(@repository.id, build.id)
    if current_administrator
      redirect_to dashboard_repositories_path, notice: 'Repository was successfully rebuilt.'
    elsif current_author
      redirect_to settings_author_repositories_path, notice: 'Repository was successfully rebuilt.'
    end
  end

  def toggle_banned_status
    @repository.toggle!(:banned)
    redirect_to dashboard_repositories_path
  end

  private

  def set_repository
    @repository = Repository.find_by(id: params[:id])
  end

  def require_author_or_admin_authentication
    repository = Repository.find(params[:id])
    return if administrator_signed_in? || current_author.id == repository.author_id

    redirect_to root_path, alert: 'Please sign as author or administrator'
  end
end
