module SystemDashboards
  class AuthorsController < SystemDashboards::ApplicationController
    def after_resource_updated_path(_requested_resource)
      system_dashboards_authors_path
    end

    # See https://administrate-demo.herokuapp.com/customizing_controller_actions
    # for more information
  end
end
