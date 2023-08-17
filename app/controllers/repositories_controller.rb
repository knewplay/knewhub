class RepositoriesController < ApplicationController
  before_action :require_author_authentication

  def update
    PullGithubRepoJob.perform_async(params[:id])
    redirect_to author_dashboards_repository_path(params[:id])
  end
end
