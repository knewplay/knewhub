require 'rails_helper'

RSpec.describe 'Administrator', type: :system do
  before(:all) do
    admin = Administrator.create(name: 'admin', password: 'password')
    WebauthnCredential.create(
      administrator_id: admin.id,
      external_id: 'id',
      public_key: 'key',
      nickname: 'nickname',
      sign_count: 1
    )
  end

  scenario 'sign in' do
    visit new_sessions_administrator_path
    expect(page).to have_content('Administrator Sign In')

    fill_in('Name', with: 'admin')
    fill_in('Password', with: 'password')

    click_on 'Sign In'

    have_current_path(system_dashboards_root_path, only_path: true)
    expect(page).to have_content('Admin: admin')
    expect(page).to have_link('Sign out')
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
