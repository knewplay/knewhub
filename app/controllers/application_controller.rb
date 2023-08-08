class ApplicationController < ActionController::Base
  include AuthorAuthentication
  include AdministratorAuthentication
end
