require 'rails_helper'
require 'support/omniauth'

RSpec.describe 'Sign in with GitHub', type: :system do
  xscenario 'with valid credentials' do
    visit root_path
    expect(page).to have_no_button('Sign out')

    click_on 'Login with GitHub'
    expect(page).to have_content('user')
    expect(page).to have_button('Sign out')
  end
end
