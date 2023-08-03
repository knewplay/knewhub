class RepositoriesController < ApplicationController
  def update
    PullGithubRepoJob.perform_async(params[:id])
    redirect_to author_admin_repository_path(params[:id])
  end
end
