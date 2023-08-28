module SystemDashboards
  class RepositoriesController < SystemDashboards::ApplicationController
    # See https://administrate-demo.herokuapp.com/customizing_controller_actions
    # for more information

    def default_sorting_attribute
      :id
    end
  end
end
