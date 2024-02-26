require 'rails_helper'

RSpec.shared_context 'when updating an author' do
  before do
    sign_in author.user
    visit edit_settings_author_path
  end
end

RSpec.describe 'Settings::Author#update', type: :system do
  let(:author) { create(:author) }

  context 'when signed in as an author' do
    include_context 'when updating an author'

    it 'displays information about current author' do
      expect(page).to have_content(author.github_username)
    end
  end

  context 'when not signed in as an author' do
    it 'redirects to root path' do
      visit edit_settings_author_path

      expect(page).to have_current_path(root_path)
      expect(page).to have_content('Please link your GitHub account.')
    end
  end

  context 'when given a valid name' do
    include_context 'when updating an author'

    it 'updates successfully' do
      expect(page).to have_content('Author profile')
      fill_in('Name', with: 'a-new-name')
      click_on 'Update Author'

      expect(page).to have_content('Author was successfully updated.')
      expect(page).to have_content('a-new-name')
    end
  end

  context 'when given an invalid name' do
    include_context 'when updating an author'

    it 'fails to update' do
      expect(page).to have_content('Author profile')
      fill_in('Name', with: 'invalid_name')
      click_on 'Update Author'

      expect(page).to have_content('Name can only contain alphanumeric characters and dashes')
      expect(page).to have_current_path(edit_settings_author_path)
    end
  end
end
