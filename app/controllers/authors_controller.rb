class AuthorsController < ApplicationController
  include AuthorAuthentication
  before_action :require_author_authentication

  def show
    @author = Author.find(current_author.id)
  end
end
