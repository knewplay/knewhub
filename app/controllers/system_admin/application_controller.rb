# All Administrate controllers inherit from this
# `Administrate::ApplicationController`, making it the ideal place to put
# authentication logic or other before_actions.
#
# If you want to add pagination or other controller-level concerns,
# you're free to overwrite the RESTful controller actions.
module SystemAdmin
  class ApplicationController < Administrate::ApplicationController
    include AdministratorAuthentication
    before_action :require_administrator_authentication
  end
end
