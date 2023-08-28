class RepositoriesController < ApplicationController
  before_action :require_authentication

  def update
    PullGithubRepoJob.perform_async(params[:id])
    if current_administrator
      redirect_to system_dashboards_repositories_path
    elsif current_author
      redirect_to author_dashboards_repository_path(params[:id])
    end
  end

  def toggle_banned_status
    @repository = Repository.find(params[:id])
    @repository.toggle!(:banned)
    if current_administrator
      redirect_to system_dashboards_repositories_path
    elsif current_author
      redirect_to author_dashboards_repository_path(@repository)
    end
  end

  private

  def require_authentication
    repository = Repository.find(params[:id])
    return if administrator_signed_in? || current_author.id == repository.author_id

    redirect_to root_path, alert: 'Please sign as author or administrator'
  end
end
