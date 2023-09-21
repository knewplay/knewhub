class Sessions::AdministratorsController < ApplicationController
  def new; end

  def create
    administrator = Administrator.find_by(name: params[:name])

    if administrator&.authenticate(params[:password])
      if administrator.multi_factor_enabled?
        session[:webauthn_administrator_id] = administrator.id
        redirect_to new_webauthn_authentication_path
      else
        session[:administrator_id] = administrator.id
        session[:administrator_expires_at] = Time.now + 1.hour
        redirect_to dashboard_root_path
      end
      session[:author_id] = nil if session[:author_id]
    else
      redirect_to root_path, alert: 'Login failed. Please verify your username and password.'
    end
  end

  def destroy
    session[:administrator_id] = nil
    session[:administrator_expires_at] = nil
    redirect_to root_path
  end
end
