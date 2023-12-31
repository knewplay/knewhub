module AuthorAuthentication
  extend ActiveSupport::Concern

  included do
    protect_from_forgery with: :exception
    helper_method :current_author

    def require_author_authentication
      redirect_to root_path, alert: 'Please log in with GitHub.' unless author_logged_in?
    end

    def current_author
      @current_author ||= Author.find(session[:author_id]) if session[:author_id]
    end

    def author_logged_in?
      !!current_author
    end
  end
end
