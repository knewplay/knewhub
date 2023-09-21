module AdministratorAuthentication
  extend ActiveSupport::Concern

  included do
    protect_from_forgery with: :exception
    helper_method :current_administrator

    def require_administrator_authentication
      return if administrator_signed_in?

      redirect_to new_sessions_administrator_path, alert: 'Please log in as an administrator.'
    end

    def require_multi_factor_authentication
      return if current_administrator.multi_factor_enabled?

      redirect_to webauthn_credentials_path,
                  alert: 'A multi-factor authentication method must be added before proceeding to the dashboard.'
    end

    def current_administrator
      validate_session
      @current_administrator ||= Administrator.find(session[:administrator_id]) if session[:administrator_id]
    end

    def administrator_signed_in?
      !!current_administrator
    end

    def validate_session
      return if session[:administrator_expires_at].nil?

      session[:administrator_id] = nil if session[:administrator_expires_at] < Time.now
    end
  end
end
