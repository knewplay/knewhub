require 'rails_helper'

RSpec.describe 'Administrator#create', type: :system do
  it 'create account with valid credentials' do
    before_count = Administrator.count

    visit new_administrator_path
    expect(page).to have_content('New Administrator')

    fill_in('Name', with: 'admin')
    fill_in('Password', with: 'password')
    fill_in('Password confirmation', with: 'password')

    click_on 'Create account'

    expect(page).to have_content('Administrator account successfully created.')
    expect(Administrator.count).to eq(before_count + 1)
  end

  it 'create account fails with invalid password confirmation' do
    before_count = Administrator.count

    visit new_administrator_path
    expect(page).to have_content('New Administrator')

    fill_in('Name', with: 'admin')
    fill_in('Password', with: 'password')
    fill_in('Password confirmation', with: 'password-typo')

    click_on 'Create account'

    expect(page).to have_current_path(new_administrator_path)
    expect(page).to have_content("Password confirmation doesn't match Password")
    expect(Administrator.count).to eq(before_count)
  end

  it 'access to create account page fails when an administrator already exists' do
    Administrator.create(name: 'admin', password: 'password')

    visit new_administrator_path
    expect(page).to have_content('Invalid action.')
  end
end
