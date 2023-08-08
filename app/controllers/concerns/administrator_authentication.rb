module AdministratorAuthentication
  extend ActiveSupport::Concern

  included do
    protect_from_forgery with: :exception
    helper_method :current_administrator

    def require_administrator_authentication
      return if administrator_signed_in?

      redirect_to new_sessions_administrator_path, alert: 'Please sign in as an administrator.'
    end

    def current_administrator
      @current_administrator ||= Administrator.find(session[:administrator_id]) if session[:administrator_id]
    end

    def administrator_signed_in?
      !!current_administrator
    end
  end
end
