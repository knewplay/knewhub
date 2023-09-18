require 'rails_helper'
require 'webauthn/fake_client'

RSpec.describe 'Sessions::Administrators#create', type: :system do
  before(:all) do
    @admin = create(:administrator)
  end

  context 'login without multi-factor authentication' do
    scenario 'redirects to set up MFA' do
      visit new_sessions_administrator_path
      expect(page).to have_content('Administrator login')

      fill_in('Name', with: 'admin')
      fill_in('Password', with: 'password')

      click_on 'Log in'

      expect(page).to have_current_path(webauthn_credentials_path)
      expect(page).to have_content('Edit multi-factor authentication')
      expect(page).to have_button('Add')
    end
  end

  context 'login with multi-factor authentication' do
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
      expect(page).to have_content('Administrator login')

      fill_in('Name', with: 'admin')
      fill_in('Password', with: 'password')

      click_on 'Log in'

      expect(page).to have_button('Authenticate')
    end
  end

  scenario 'login fails with wrong username' do
    visit new_sessions_administrator_path

    fill_in('Name', with: 'other')
    fill_in('Password', with: 'password')

    click_on 'Log in'

    expect(page).to have_content('Login failed. Please verify your username and password.')
  end

  scenario 'login fails with wrong password' do
    visit new_sessions_administrator_path

    fill_in('Name', with: 'admin')
    fill_in('Password', with: 'password-typo')

    click_on 'Log in'

    expect(page).to have_content('Login failed. Please verify your username and password.')
  end
end
