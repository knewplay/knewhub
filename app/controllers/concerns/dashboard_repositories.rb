module DashboardRepositories
  extend ActiveSupport::Concern

  included do
    # Override `update` action to call background jobs
    def update
      former_name = requested_resource.name
      former_branch = requested_resource.branch

      if requested_resource.update(resource_params)
        if former_name != requested_resource.name || former_branch != requested_resource.branch
          old_directory = Rails.root.join('repos', requested_resource.author.github_username, former_name)
          FileUtils.remove_dir(old_directory) if Dir.exist?(old_directory)
          CloneGithubRepoJob.perform_async(requested_resource.id)
        else
          PullGithubRepoJob.perform_async(requested_resource.id)
        end
        redirect_to(
          after_resource_updated_path(requested_resource),
          notice: translate_with_resource('update.success')
        )
      else
        render :edit, locals: {
          page: Administrate::Page::Form.new(dashboard, requested_resource)
        }, status: :unprocessable_entity
      end
    end
  end
end
