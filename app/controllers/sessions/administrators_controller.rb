class Sessions::AdministratorsController < ApplicationController
  def new; end

  def create
    administrator = Administrator.find_by(name: params[:name])

    if administrator&.authenticate(params[:password])
      session[:administrator_id] = administrator.id
      redirect_to system_admin_root_path
    else
      redirect_to root_path, alert: 'Sign in failed. Please verify your username and password.'
    end
  end

  def destroy
    session[:administrator_id] = nil
    redirect_to root_path
  end
end
