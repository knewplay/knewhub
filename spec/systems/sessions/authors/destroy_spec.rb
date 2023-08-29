require 'rails_helper'
require 'support/omniauth'

RSpec.describe 'Logout from GitHub auth session', type: :system do
  xscenario 'started with valid credentials' do
    visit root_path

    click_on 'Login with GitHub'
    expect(page).to have_content('user')

    click_on 'Sign out'
    expect(page).not_to have_content('user')
    expect(page).to have_button('Login with GitHub')
  end
end
