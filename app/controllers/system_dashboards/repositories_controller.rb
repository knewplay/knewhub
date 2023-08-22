module SystemDashboards
  class RepositoriesController < SystemDashboards::ApplicationController
    # Concern overrides #update action of the Administrate::Administrate::ApplicationController
    # to be able to call background jobs
    include DashboardRepositories

    def after_resource_updated_path(_requested_resource)
      system_dashboards_repositories_path
    end

    # See https://administrate-demo.herokuapp.com/customizing_controller_actions
    # for more information
  end
end
