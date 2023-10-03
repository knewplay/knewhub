module Settings
  module Authors
    module Repositories
      class BuildsController < ApplicationController
        before_action :require_author_authentication, :set_repository

        def index
          @builds = @repository.builds.order(created_at: :desc)
        end

        private

        def set_repository
          @repository = Repository.find_by(id: params[:repository_id], author_id: current_author.id)
        end
      end
    end
  end
end
