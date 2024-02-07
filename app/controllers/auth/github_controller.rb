module Auth
  class GithubController < ApplicationController
    def create
      current_author.update(installation_id: params[:installation_id])
      redirect_to root_path
    end
  end
end
