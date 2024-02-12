module Settings
  module Authors
    class RepositoriesController < ApplicationController
      layout 'settings'

      before_action :require_author_authentication
      before_action :set_repository, only: %i[edit update destroy]
      before_action :set_available_repositories, only: %i[available new]
      before_action :verify_if_available_repository, only: [:new]

      def index
        @repositories = current_author.repositories.order('id ASC')
      end

      def available; end

      def new
        full_name = params[:full_name]
        owner, name = full_name.split('/')
        @repository = current_author.repositories.build(name:, owner:)
      end

      def edit; end

      def create
        @repository = current_author.repositories.build(repository_params)
        if @repository.save
          build = Build.create(repository: @repository, status: 'In progress', action: 'create')
          build.create_repo
          redirect_to settings_author_repositories_path,
                      notice: 'Repository creation process was initiated. Check Builds for progress and details.'
        else
          render :new, status: :unprocessable_entity
        end
      end

      def update
        former_branch = @repository.branch

        if @repository.update(repository_params)
          build = Build.create(repository: @repository, status: 'In progress', action: 'update')
          directory = Rails.root.join('repos', @repository.owner, @repository.name)
          update_actions(build, directory, former_branch)
          redirect_to settings_author_repositories_path,
                      notice: 'Repository update process was initiated. Check Builds for progress and details.'
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        github_username = @repository.author.github_username
        name = @repository.name
        directory = Rails.root.join('repos', github_username, name)

        RemoveRepoJob.perform_async(github_username, name, @repository.hook_id, @repository.token, directory.to_s)
        @repository.destroy
        redirect_to settings_author_repositories_path, notice: 'Repository was successfully deleted.'
      end

      private

      def set_repository
        @repository = Repository.find_by(id: params[:id], author_id: current_author.id)
      end

      def repository_params
        params.require(:repository).permit(:name, :owner, :branch, :title)
      end

      def update_actions(build, directory, former_branch)
        if former_branch == @repository.branch
          build.update_repo('pull')
        else
          FileUtils.rm_r(directory) if Dir.exist?(directory)
          build.update_repo('clone')
        end
      end

      def set_available_repositories
        @available_repositories = current_author.repositories_available_for_addition
      end

      def verify_if_available_repository
        return if @available_repositories.include?(params[:full_name])

        redirect_to root_path, alert: 'You are not have permission to add this repository.'
      end
    end
  end
end
