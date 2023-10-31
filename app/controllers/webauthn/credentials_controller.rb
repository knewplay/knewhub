module Webauthn
  class CredentialsController < ApplicationController
    before_action :require_administrator_authentication

    def index
      credentials = current_administrator.webauthn_credentials.order(created_at: :desc)

      render :index, locals: { credentials: }
    end

    def options
      current_administrator.update!(webauthn_id: WebAuthn.generate_user_id) unless current_administrator.webauthn_id

      create_options = WebAuthn::Credential.options_for_create(
        user: {
          id: current_administrator.webauthn_id,
          name: current_administrator.name
        },
        exclude: current_administrator.webauthn_credentials.pluck(:external_id)
      )

      session[:current_challenge] = create_options.challenge
      render json: create_options
    end

    def create
      webauthn_credential = WebAuthn::Credential.from_create(params[:credential])

      begin
        webauthn_credential.verify(session[:current_challenge])

        credential = current_administrator.webauthn_credentials.build(
          external_id: webauthn_credential.id,
          nickname: params[:nickname],
          public_key: webauthn_credential.public_key,
          sign_count: webauthn_credential.sign_count
        )

        if credential.save
          render :create, locals: { credential: }, status: :created
        else
          render turbo_stream: turbo_stream.update('webauthn_credential_error', "<p>Couldn't add your Security Key</p>")
        end
      rescue WebAuthn::Error => e
        render turbo_stream: turbo_stream.update(
          'webauthn_credential_error',
          "<p>Verification failed: #{e.message}</p>"
        )
      end
      session.delete(:current_challenge)
    end

    def destroy
      credential = current_administrator.webauthn_credentials.find(params[:id])
      credential.destroy

      render turbo_stream: turbo_stream.remove(credential)
    end
  end
end
