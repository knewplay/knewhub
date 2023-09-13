class AdministratorsController < ApplicationController
  before_action :verify_allow_create

  def new
    @administrator = Administrator.new
  end

  def create
    @administrator = Administrator.new(administrator_params)

    if @administrator.save
      redirect_to root_path, notice: 'Administrator account successfully created.'
    else
      redirect_to root_path, alert: 'Creation of administrator account failed.'
    end
  end

  private

  def administrator_params
    params.require(:administrator).permit(:name, :password, :password_confirmation)
  end

  def verify_allow_create
    redirect_to root_path, alert: 'Invalid action.' unless empty_table || current_administrator&.permissions == 'admin'
  end

  def empty_table
    return true if Administrator.any? == false
  end
end
