module AuthorAdmin
  class ApplicationController < Administrate::ApplicationController
    include AuthorAuthentication
    before_action :require_author_authentication
  end
end
