module SystemDashboards
  class RepositoriesController < SystemDashboards::ApplicationController
    # Concern overrides #update action of the Administrate::Administrate::ApplicationController
    # to be able to call background jobs
    include DashboardRepositories

    # See https://administrate-demo.herokuapp.com/customizing_controller_actions
    # for more information
  end
end
