class Sessions::AuthorsController < ApplicationController
  before_action :authenticate_user!

  def create
    @author = Author.from_omniauth(request.env['omniauth.auth'])
    if @author.persisted?
      @author.update(user: current_user) if @author.user.nil?
      session[:author_id] = @author.id
      redirect_to settings_root_path
    else
      redirect_to root_url, alert: 'Failure'
    end
  end

  def destroy
    session[:author_id] = nil
    redirect_to root_path
  end
end
