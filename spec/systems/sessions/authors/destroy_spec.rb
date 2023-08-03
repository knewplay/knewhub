require 'rails_helper'

RSpec.describe 'Author', type: :system do
  scenario 'sign out' do
    visit root_path

    click_on 'Login with GitHub'
    expect(page).to have_content('some_user')

    click_on 'Sign out'
    expect(page).not_to have_content('some_user')
    expect(page).to have_button('Login with GitHub')
  end
end
