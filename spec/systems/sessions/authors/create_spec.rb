require 'rails_helper'
require 'support/omniauth'

RSpec.describe 'Sessions::Authors#create', type: :system do
  context 'when logged in as a user' do
    let(:author) { create(:author) }

    it 'can log in as an author' do
      sign_in author.user
      visit settings_root_path

      click_on 'Login with GitHub'
      expect(page).to have_content("Logged in as #{author.name}")
    end
  end

  context 'when not logged in as a user' do
    it 'cannot access log in as an author page' do
      visit settings_root_path

      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_content('You need to log in or create an account before continuing.')
    end
  end
end
