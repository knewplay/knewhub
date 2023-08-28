module AuthorSpace
  class RepositoriesController < ApplicationController
    before_action :require_author_authentication

    def index
      @repositories = current_author.repositories.order('id ASC')
    end
  end
end
