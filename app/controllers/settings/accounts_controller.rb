module Settings
  class AccountsController < ApplicationController
    layout 'settings'

    before_action :authenticate_user!

    # GET  /settings/account
    def show; end
  end
end
