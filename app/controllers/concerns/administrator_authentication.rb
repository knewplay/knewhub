module AdministratorAuthentication
  extend ActiveSupport::Concern

  included do
    protect_from_forgery with: :exception
    helper_method :current_administrator

    def require_administrator_authentication
      return if administrator_signed_in?

      redirect_to new_sessions_administrator_path, alert: 'Please sign in as an administrator.'
    end

    def require_multi_factor_authentication
      return if current_administrator.multi_factor_enabled?

      redirect_to webauthn_credentials_path
    end

    def current_administrator
      @current_administrator ||= Administrator.find(session[:administrator_id]) if session[:administrator_id]
    end

    def administrator_signed_in?
      !!current_administrator
    end
  end
end
