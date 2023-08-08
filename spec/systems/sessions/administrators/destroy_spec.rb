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

  scenario 'sign out' do
    visit new_sessions_administrator_path
    expect(page).to have_content('Administrator Sign In')

    fill_in('Name', with: 'admin')
    fill_in('Password', with: 'password')

    click_on 'Sign In'

    expect(page).to have_current_path(system_dashboards_root_path)
    click_on 'Sign out'

    expect(page).to have_current_path(root_path)
  end
end
