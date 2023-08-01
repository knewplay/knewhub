module AuthorAdmin
  class RepositoriesController < AuthorAdmin::ApplicationController
    # Override `create` action to add association to `current_author`
    # and to call background jobs
    def create
      params[:repository][:author_id] = current_author.id
      resource = new_resource(resource_params)
      authorize_resource(resource)

      if resource.save
        CreateGithubWebhookJob.perform_async(
          resource.uuid,
          resource.name,
          resource.author.github_username,
          resource.token
        )
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

    def update
      super
      # Call Job to pull the repo
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
