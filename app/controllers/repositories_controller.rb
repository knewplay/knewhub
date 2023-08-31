class RepositoriesController < ApplicationController
  before_action :require_author_or_admin_authentication, only: [:update]
  before_action :require_administrator_authentication, only: [:toggle_banned_status]

  def update
    PullGithubRepoJob.perform_async(params[:id])
    if current_administrator
      redirect_to dashboard_repositories_path
    elsif current_author
      redirect_to settings_author_repositories_path
    end
  end

  def toggle_banned_status
    @repository = Repository.find(params[:id])
    @repository.toggle!(:banned)
    redirect_to dashboard_repositories_path
  end

  private

  def require_author_or_admin_authentication
    repository = Repository.find(params[:id])
    return if administrator_signed_in? || current_author.id == repository.author_id

    redirect_to root_path, alert: 'Please sign as author or administrator'
  end
end
