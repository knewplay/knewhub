require 'rails_helper'

RSpec.describe 'Settings::Author#update', type: :system do
  let(:author) { create(:author) }

  context 'when signed in as an author' do
    scenario 'displays information about current author' do
      sign_in author.user
      page.set_rack_session(author_id: author.id)

      visit edit_settings_author_path
      expect(page).to have_content(author.github_username)
    end
  end

  context 'when not signed in as an author' do
    scenario 'redirects to root path' do
      visit edit_settings_author_path

      expect(page).to have_current_path(root_path)
      expect(page).to have_content('Please log in with GitHub.')
    end
  end

  context 'when given a valid name' do
    scenario 'updates successfully' do
      sign_in author.user
      page.set_rack_session(author_id: author.id)
      visit edit_settings_author_path

      expect(page).to have_content('Author profile')
      fill_in('Name', with: 'a-new-name')
      click_on 'Update Author'

      expect(page).to have_content('Author was successfully updated.')
      expect(page).to have_content('a-new-name')
    end
  end

  context 'when given an invalid name' do
    scenario 'fails to update' do
      sign_in author.user
      page.set_rack_session(author_id: author.id)
      visit edit_settings_author_path

      expect(page).to have_content('Author profile')
      fill_in('Name', with: 'invalid_name')
      click_on 'Update Author'

      expect(page).to have_content('Name can only contain alphanumeric characters and dashes')
      expect(page).to have_current_path(edit_settings_author_path)
    end
  end
end
