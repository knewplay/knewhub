module Sessions
  class AdministratorsController < ApplicationController
    def new; end

    def create
      if (administrator = Administrator.authenticate_by(name: params[:name], password: params[:password]))
        if administrator.multi_factor_enabled?
          session[:webauthn_administrator_id] = administrator.id
          redirect_to new_webauthn_authentication_path
        else
          session[:administrator_id] = administrator.id
          session[:administrator_expires_at] = Time.now + 1.hour
          redirect_to dashboard_root_path
        end
        destroy_other_sessions
      else
        redirect_to new_sessions_administrator_path, alert: 'Login failed. Please verify your username and password.'
      end
    end

    def destroy
      session[:administrator_id] = nil
      session[:administrator_expires_at] = nil
      redirect_to root_path
    end

    def destroy_other_sessions
      session[:user_id] = nil if session[:user_id]
      session[:author_id] = nil if session[:author_id]
    end
  end
end
