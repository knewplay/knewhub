module AuthorSpace
  class RepositoriesController < ApplicationController
    before_action :require_author_authentication
    before_action :set_repository, only: %i[edit update]

    def index
      @repositories = current_author.repositories.order('id ASC')
    end

    def edit
      render file: "#{Rails.root}/public/404.html", layout: false, status: :not_found if @repository.nil?
    end

    def update
      former_name = @repository.name
      former_branch = @repository.branch

      if @repository.update(repository_params)
        if former_name != @repository.name || former_branch != @repository.branch
          old_directory = Rails.root.join('repos', @repository.author.github_username, former_name)
          FileUtils.remove_dir(old_directory) if Dir.exist?(old_directory)
          CloneGithubRepoJob.perform_async(@repository.id)
        else
          PullGithubRepoJob.perform_async(@repository.id)
        end
        redirect_to author_repositories_path, notice: 'Repository was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_repository
      @repository = Repository.find_by(id: params[:id], author_id: current_author.id)
    end

    def repository_params
      params.require(:repository).permit(:name, :title, :branch)
    end
  end
end
