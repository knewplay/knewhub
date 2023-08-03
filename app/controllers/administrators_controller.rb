class AdministratorsController < ApplicationController
  def new
    @administrator = Administrator.new
  end

  def create
    @administrator = Administrator.new(administrator_params)

    if @administrator.save
      redirect_to root_path, notice: 'Signed up successfully.'
    else
      redirect_to root_path, alert: 'Sign up failed.'
    end
  end

  private

  def administrator_params
    params.require(:administrator).permit(:name, :password, :password_confirmation)
  end
end
