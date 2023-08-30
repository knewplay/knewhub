module Settings
  class EnableAuthorController < ApplicationController
    before_action :authenticate_user!, :user_is_not_an_author

    def show; end

    private

    def user_is_not_an_author
      return if current_user.author.nil?

      redirect_to settings_root_path,
                  notice: "This user account is already associated with author #{current_user.author.name}."
    end
  end
end
