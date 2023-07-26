class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_author

  def require_author_authentication
    redirect_to root_path, alert: 'Requires authentication' unless author_signed_in?
  end

  def current_author
    @current_author ||= Author.find(session[:author_id]) if session[:author_id]
  end

  def author_signed_in?
    !!current_author
  end
end
