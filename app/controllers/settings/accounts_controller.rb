module Settings
  class AccountsController < ApplicationController
    layout 'settings'

    before_action :authenticate_user!

    def show; end
  end
end
