class Auth::GithubController < ApplicationController
  def create
    @author = Author.from_omniauth(request.env['omniauth.auth'])
    if @author.persisted?
      session[:author_id] = @author.id
      redirect_to root_url, notice: "Logged in as #{@author.github_username}"
    else
      redirect_to root_url, alert: 'Failure'
    end
  end

  def destroy
    session[:author_id] = nil
    redirect_to root_path
  end
end
