require 'rails_helper'
require 'support/omniauth'

RSpec.describe 'Sessions::Authors#destroy', type: :system do
  context 'when logging out as a user' do
    let(:author) { create(:author) }

    scenario 'it also logs out as an author' do
      page.set_rack_session(author_id: author.id)
      sign_in author.user

      visit root_path
      click_on 'Logout'

      visit settings_author_repositories_path
      expect(page).to have_content('Please log in with GitHub.')
    end
  end
end
