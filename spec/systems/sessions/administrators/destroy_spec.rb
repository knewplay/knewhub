require 'rails_helper'

RSpec.describe 'Administrator', type: :system do
  before(:all) do
    Administrator.create(name: 'admin', password: 'password')
  end

  scenario 'sign out' do
    visit new_sessions_administrator_path
    expect(page).to have_content('Administrator Sign In')

    fill_in('Name', with: 'admin')
    fill_in('Password', with: 'password')

    click_on 'Sign In'

    expect(page).to have_current_path(system_admin_root_path)
    click_on 'Sign out'

    expect(page).to have_current_path(root_path)
  end
end
