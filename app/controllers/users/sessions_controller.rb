class Users::SessionsController < Devise::SessionsController
  # POST /resource/sign_in
  def create
    super
    session[:administrator_id] = nil if session[:administrator_id]
  end

  # DELETE /resource/sign_out
  def destroy
    super
    session[:author_id] = nil
  end
end
