require 'rails_helper'

RSpec.describe 'User::Sessions#create', type: :system do
  let(:user) { create(:user) }

  context 'when given valid credentials' do
    scenario 'signs in the user' do
      visit new_user_session_path

      fill_in('Email', with: user.email)
      fill_in('Password', with: user.password)

      click_button 'Login'

      expect(page).to have_content('Signed in successfully.')
    end
  end

  context 'when given invalid credentials' do
    scenario 'sign in fails' do
      visit new_user_session_path

      fill_in('Email', with: 'unregistered_email@example.com')
      fill_in('Password', with: user.password)

      click_button 'Login'

      expect(page).to have_content('Invalid Email or password.')
    end
  end
end
