module Dashboard
  class ApplicationController < Administrate::ApplicationController
    include AdministratorAuthentication
    before_action :require_administrator_authentication, :require_multi_factor_authentication
  end
end
