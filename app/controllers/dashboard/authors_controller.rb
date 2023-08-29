module Dashboard
  class AuthorsController < Dashboard::ApplicationController
    def after_resource_updated_path(_requested_resource)
      dashboard_authors_path
    end

    def default_sorting_attribute
      :id
    end

    # See https://administrate-demo.herokuapp.com/customizing_controller_actions
    # for more information
  end
end
