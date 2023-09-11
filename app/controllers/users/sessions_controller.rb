class Users::SessionsController < Devise::SessionsController
  def create
    super
    session[:administrator_id] = nil if session[:administrator_id]
  end

  def destroy
    super
    session[:author_id] = nil
  end
end
