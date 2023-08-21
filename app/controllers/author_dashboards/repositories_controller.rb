module AuthorDashboards
  class RepositoriesController < AuthorDashboards::ApplicationController
    # Concern overrides #update action of the Administrate::Administrate::ApplicationController
    # to be able to call background jobs
    include DashboardRepositories

    # Override `create` action to add association to `current_author`
    # and to call background jobs
    def create
      params[:repository][:author_id] = current_author.id
      resource = new_resource(resource_params)
      authorize_resource(resource)

      if resource.save
        CreateGithubWebhookJob.perform_async(resource.id)
        CloneGithubRepoJob.perform_async(resource.id)
        redirect_to(
          after_resource_created_path(resource),
          notice: translate_with_resource('create.success')
        )
      else
        render :new, locals: {
          page: Administrate::Page::Form.new(dashboard, resource)
        }, status: :unprocessable_entity
      end
    end

    # Override `destroy` action to delete local repository
    def destroy
      directory = Rails.root.join('repos', current_author.github_username, requested_resource.name)
      if requested_resource.destroy
        flash[:notice] = translate_with_resource('destroy.success')
        FileUtils.remove_dir(directory) if Dir.exist?(directory)
      else
        flash[:error] = requested_resource.errors.full_messages.join('<br/>')
      end
      redirect_to after_resource_destroyed_path(requested_resource)
    end

    # For `index` action, only show repositories belonging to the author currently authentified
    def scoped_resource
      @repositories = current_author.repositories if current_author
    end

    # Override `resource_params` to add `author_id` as an allowed field
    def resource_params
      params.require(resource_class.model_name.param_key)
            .permit(dashboard.permitted_attributes(action_name) << :author_id)
            .transform_values { |v| read_param_value(v) }
    end

    # See https://administrate-demo.herokuapp.com/customizing_controller_actions
    # for more information
  end
end
