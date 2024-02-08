require 'rails_helper'

RSpec.describe 'Settings::EnableAuthor#get', type: :system do
  let!(:user) { create(:user) }

  context 'when logged in as a user but not an author' do
    it 'displays the page to enable the feature' do
      sign_in user
      visit settings_enable_author_path

      expect(page).to have_content('Share your knowledge by becoming an author on KNEWHUB.')
    end
  end

  context 'when logged in as a user and an author' do
    let(:author) { create(:author, user:) }

    it 'cannot access this page' do
      sign_in author.user

      visit settings_enable_author_path
      expect(page).to have_content("This user account is already associated with author #{author.name}.")
    end
  end
end
