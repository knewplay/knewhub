require 'rails_helper'

RSpec.describe 'Administrator', type: :system do
  scenario 'sign up with valid credentials' do
    before_count = Administrator.count

    visit new_administrator_path
    expect(page).to have_content('New Administrator')

    fill_in('Name', with: 'admin')
    fill_in('Password', with: 'password')
    fill_in('Password confirmation', with: 'password')

    click_on 'Sign Up'

    expect(page).to have_content('Signed up successfully.')
    expect(Administrator.count).to eq(before_count + 1)
  end

  scenario 'sign up fails with invalid password confirmation' do
    before_count = Administrator.count

    visit new_administrator_path
    expect(page).to have_content('New Administrator')

    fill_in('Name', with: 'admin')
    fill_in('Password', with: 'password')
    fill_in('Password confirmation', with: 'password-typo')

    click_on 'Sign Up'

    expect(page).to have_content('Sign up failed.')
    expect(Administrator.count).to eq(before_count)
  end

  scenario 'access to sign up page fails when an administrator already exists' do
    Administrator.create(name: 'admin', password: 'password')

    visit new_administrator_path
    expect(page).to have_content('Invalid action.')
  end
end
