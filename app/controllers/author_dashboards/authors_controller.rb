module AuthorDashboards
  class AuthorsController < AuthorDashboards::ApplicationController
    def after_resource_updated_path(_requested_resource)
      author_dashboards_root_path
    end

    # See https://administrate-demo.herokuapp.com/customizing_controller_actions
    # for more information
  end
end
