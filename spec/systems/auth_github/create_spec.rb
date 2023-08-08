require 'rails_helper'

RSpec.describe 'Sign in with GitHub', type: :system do
  scenario 'valid credentials' do
    visit root_path
    expect(page).to have_no_button('Sign out')

    click_on 'Login with GitHub'
    expect(page).to have_content('some_user')
    expect(page).to have_link('Sign out')
  end
end
