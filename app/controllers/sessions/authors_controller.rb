
class Sessions::AuthorsController < ApplicationController
  def create
    @author = Author.from_omniauth(request.env['omniauth.auth'])
    if @author.persisted?
      session[:author_id] = @author.id
      session[:administrator_id] = nil if session[:administrator_id]
      redirect_to author_dashboards_root_path
    else
      redirect_to root_url, alert: 'Failure'
    end
  end

  def destroy
    session[:author_id] = nil
    redirect_to root_path
  end
end
