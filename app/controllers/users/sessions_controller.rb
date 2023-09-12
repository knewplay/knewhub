class Users::SessionsController < Devise::SessionsController
  def create
    super
    if session[:administrator_id]
      session[:administrator_id] = nil
      session[:administrator_expires_at] = nil
    end
  end

  def destroy
    super
    session[:author_id] = nil
  end
end
