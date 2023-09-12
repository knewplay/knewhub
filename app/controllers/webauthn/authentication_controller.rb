class Webauthn::AuthenticationController < ApplicationController
  before_action :ensure_administrator_not_authenticated
  before_action :ensure_login_initiated

  def new
    @administrator = administrator
  end

  def options
    get_options = WebAuthn::Credential.options_for_get(allow: administrator.webauthn_credentials.pluck(:external_id))

    session[:authentication_challenge] = get_options.challenge

    render json: get_options
  end

  def create
    webauthn_credential = WebAuthn::Credential.from_get(params)

    credential = administrator.webauthn_credentials.find_by(external_id: webauthn_credential.id)

    begin
      webauthn_credential.verify(
        session[:authentication_challenge],
        public_key: credential.public_key,
        sign_count: credential.sign_count
      )

      credential.update!(sign_count: webauthn_credential.sign_count)
      session[:administrator_id] = session[:webauthn_administrator_id]
      session[:administrator_expires_at] = Time.now + 1.hour
      session[:webauthn_administrator_id] = nil

      # Pass `redirect URL` to Stimulus controller. Rails `redirect_to` does not work
      render json: { redirect: dashboard_root_path }, status: :ok
    rescue WebAuthn::Error => e
      render json: "Verification failed: #{e.message}", status: :unprocessable_entity
    end
  end

  private

  def administrator
    @administrator ||= Administrator.find(session[:webauthn_administrator_id])
  end

  def ensure_login_initiated
    redirect_to new_sessions_administrator_path if session[:webauthn_administrator_id].blank?
  end

  def ensure_administrator_not_authenticated
    redirect_to root_path if current_administrator
  end
end
