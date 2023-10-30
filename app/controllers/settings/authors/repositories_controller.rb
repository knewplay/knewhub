module Settings
  module Authors
    class RepositoriesController < ApplicationController
      layout 'settings'

      before_action :require_author_authentication
      before_action :set_repository, only: %i[edit update destroy]

      def index
        @repositories = current_author.repositories.order('id ASC')
      end

      def new
        @repository = current_author.repositories.build
      end

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

      def edit
        render file: Rails.root.join('public/404.html').to_s, layout: false, status: :not_found if @repository.nil?
      end

      def update
        former_name = @repository.name
        former_branch = @repository.branch

        if @repository.update(repository_params)
          build = Build.create(repository: @repository, status: 'In progress', action: 'update')
          if former_name != @repository.name || former_branch != @repository.branch
            old_directory = Rails.root.join('repos', @repository.author.github_username, former_name)
            FileUtils.remove_dir(old_directory) if Dir.exist?(old_directory)
            build.update_repo('clone')
          else
            build.update_repo('pull')
          end
          redirect_to settings_author_repositories_path,
                      notice: 'Repository update process was initiated. Check Builds for progress and details.'
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        RemoveRepoJob.perform_async(@repository.id)
        redirect_to settings_author_repositories_path, notice: 'Repository was successfully deleted.'
      end

      private

      def set_repository
        @repository = Repository.find_by(id: params[:id], author_id: current_author.id)
      end

      def repository_params
        params.require(:repository).permit(:name, :title, :branch, :token)
      end
    end
  end
end
