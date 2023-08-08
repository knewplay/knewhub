class Webauthn::CredentialsController < ApplicationController
  before_action :require_administrator_authentication

  def new; end
end
