require 'rails_helper'

RSpec.describe 'Logout from GitHub auth session', type: :system do
  scenario 'valid credentials' do
    visit root_path

    click_button 'Login with GitHub'
    expect(page).to have_content('some_user')

    click_button 'Sign out'
    expect(page).not_to have_content('some_user')
    expect(page).to have_button('Login with GitHub')
  end
end
