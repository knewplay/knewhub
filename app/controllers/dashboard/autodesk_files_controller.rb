module Dashboard
  class AutodeskFilesController < Dashboard::ApplicationController
    def default_sorting_attribute
      :id
    end

    # See https://administrate-demo.herokuapp.com/customizing_controller_actions
    # for more information
  end
end
