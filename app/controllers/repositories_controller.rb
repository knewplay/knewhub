class RepositoriesController < ApplicationController
  before_action :require_author_or_admin_authentication, only: [:update]
  before_action :require_administrator_authentication, only: [:toggle_banned_status]
  before_action :set_repository

  # PATCH /repositories/:id
  def update
    build = Build.create(repository: @repository, status: 'In progress', action: 'rebuild')
    build.rebuild_repo
    notice_msg = 'Repository rebuild process was initiated. Check Builds for progress and details.'
    if current_administrator
      redirect_to dashboard_repositories_path, notice: notice_msg
    elsif current_author
      redirect_to settings_author_repositories_path, notice: notice_msg
    end
  end

  # PATCH /repositories/:id/toggle_banned_status
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
    return if administrator_signed_in? || current_author.id == repository.author.id

    redirect_to root_path, alert: 'Please log in as an author or administrator.'
  end
end
