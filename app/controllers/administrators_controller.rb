class AdministratorsController < ApplicationController
  before_action :verify_allow_create, only: [:new]

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

  def verify_allow_create
    redirect_to root_path, alert: 'Invalid action.' unless empty_table
  end

  def empty_table
    return true if Administrator.any? == false
  end
end