module AuthorAuthentication
  extend ActiveSupport::Concern

  included do
    protect_from_forgery with: :exception
    helper_method :current_author

    def require_author_authentication
      redirect_to root_path, alert: 'Please link your GitHub account.' unless author_logged_in?
    end

    def current_author
      return if current_user.nil?

      current_user.author
    end

    def author_logged_in?
      !!current_author
    end
  end
end
