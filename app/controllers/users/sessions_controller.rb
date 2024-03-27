module Users
  class SessionsController < Devise::SessionsController
    # POST /users/sign_in
    def create
      super
      return unless session[:administrator_id]

      session[:administrator_id] = nil
      session[:administrator_expires_at] = nil
    end
  end
end
