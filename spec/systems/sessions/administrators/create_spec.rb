require 'rails_helper'
require 'webauthn/fake_client'

RSpec.describe 'Administrator', type: :system do
  before(:all) do
    @admin = create(:administrator)
  end

  context 'sign in without multi-factor authentication' do
    scenario 'redirects to set up MFA' do
      visit new_sessions_administrator_path
      expect(page).to have_content('Administrator Sign In')

      fill_in('Name', with: 'admin')
      fill_in('Password', with: 'password')

      click_on 'Sign In'

      expect(page).to have_current_path(webauthn_credentials_path)
      expect(page).to have_content('Multi-Factor Authentication')
      expect(page).to have_button('Add')
    end
  end

  context 'sign in with multi-factor authentication' do
    before do
      @admin.update(webauthn_id: WebAuthn.generate_user_id)
      fake_client = WebAuthn::FakeClient.new('http://localhost:3030')
      public_key_credential = WebAuthn::Credential.from_create(fake_client.create)
      @admin.webauthn_credentials.create(
        nickname: 'SecurityKeyNickname',
        external_id: public_key_credential.id,
        public_key: public_key_credential.public_key,
        sign_count: '1000'
      )
      @admin.webauthn_credentials.take
    end

    scenario 'asks for MFA' do
      visit new_sessions_administrator_path
      expect(page).to have_content('Administrator Sign In')

      fill_in('Name', with: 'admin')
      fill_in('Password', with: 'password')

      click_on 'Sign In'

      expect(page).to have_button('Authenticate')
    end
  end

  scenario 'sign in fails with wrong username' do
    visit new_sessions_administrator_path

    fill_in('Name', with: 'other')
    fill_in('Password', with: 'password')

    click_on 'Sign In'

    expect(page).to have_content('Sign in failed. Please verify your username and password.')
  end

  scenario 'sign in fails with wrong password' do
    visit new_sessions_administrator_path

    fill_in('Name', with: 'admin')
    fill_in('Password', with: 'password-typo')

    click_on 'Sign In'

    expect(page).to have_content('Sign in failed. Please verify your username and password.')
  end
end
