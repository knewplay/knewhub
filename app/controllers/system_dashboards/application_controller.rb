module SystemDashboards
  class ApplicationController < Administrate::ApplicationController
    include AdministratorAuthentication
    before_action :require_administrator_authentication
  end
end
