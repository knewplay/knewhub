module Settings
  module Authors
    class RepositoriesController < ApplicationController
      layout 'settings'

      before_action :require_author_authentication
      before_action :set_repository, only: %i[edit update destroy]
      before_action :set_available_repositories, only: %i[available new]
      before_action :verify_if_available_repository, only: [:new]

      # GET /settings/author/repositories
      def index
        @repositories = current_author.repositories.order('id ASC')
      end

      # GET /settings/author/repositories/available
      def available; end

      # GET /settings/author/repositories/new
      def new
        full_name = params[:full_name]
        owner, name = full_name.split('/')
        @repository = github_installation(owner).repositories.build(name:, uid: params[:uid].to_i)
      end

      # GET /settings/author/repositories/:id/edit
      def edit; end

      # POST /settings/author/repositories
      def create
        @repository = github_installation(repository_params[:owner]).repositories
                                                                    .build(repository_params.except(:owner))
        if @repository.save
          build = Build.create(repository: @repository, status: 'In progress', action: 'create')
          build.create_repo
          redirect_to settings_author_repositories_path,
                      notice: 'Repository creation process was initiated. Check Builds for progress and details.'
        else
          render :new, status: :unprocessable_entity
        end
      end

      # PATCH /settings/author/repositories/:id
      def update
        former_branch = @repository.branch

        if @repository.update(repository_params.except(:owner))
          build = Build.create(repository: @repository, status: 'In progress', action: 'update')
          directory = @repository.storage_path
          update_actions(build, directory, former_branch)
          redirect_to settings_author_repositories_path,
                      notice: 'Repository update process was initiated. Check Builds for progress and details.'
        else
          render :edit, status: :unprocessable_entity
        end
      end

      # DELETE /settings/author/repositories/:id
      def destroy
        RemoveDirectoryJob.perform_async(@repository.storage_path.to_s)
        @repository.destroy
        redirect_to settings_author_repositories_path, notice: 'Repository was successfully deleted.'
      end

      private

      def set_repository
        @repository = Repository.includes(:github_installation)
                                .find_by(id: params[:id], github_installation: { author_id: current_author.id })
      end

      def repository_params
        params.require(:repository).permit(:uid, :name, :owner, :branch, :title)
      end

      def github_installation(username)
        GithubInstallation.find_by(author_id: current_author.id, username:)
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
      rescue Octokit::NotFound
        github_app_name = ENV.fetch('GITHUB_APP_NAME', Rails.application.credentials.dig(:github, :app_name))
        alert = <<-MSG
        It looks like we don't have access to your GitHub account anymore.
        Visit #{view_context.link_to 'this page', "https://github.com/apps/#{github_app_name}/installations/new"}
        to link your account.
        MSG
        redirect_to settings_root_path, alert:
      end

      def verify_if_available_repository
        return if @available_repositories.include?({ full_name: params[:full_name], uid: params[:uid].to_i })

        redirect_to root_path, alert: 'You are not have permission to add this repository.'
      end
    end
  end
end
