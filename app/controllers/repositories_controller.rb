class RepositoriesController < ApplicationController
  before_action :require_authentication

  def update
    PullGithubRepoJob.perform_async(params[:id])
    redirect_to author_dashboards_repository_path(params[:id])
  end

  def toggle_hidden_status
    @repository = Repository.find(params[:id])
    @repository.toggle!(:hidden)
    if current_administrator
      redirect_to edit_system_dashboards_repository_path(@repository)
    elsif current_author
      redirect_to author_dashboards_repository_path(@repository)
    end
  end

  private

  def require_authentication
    unless author_signed_in? || administrator_signed_in?
      redirect_to root_path, alert: 'Please sign as author or administrator'
    end
  end
end
