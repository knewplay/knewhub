require 'rails_helper'

RSpec.describe 'Author #update', type: :system do
  let(:author) { create(:author) }

  context 'when given a valid name' do
    scenario 'updates successfully' do
      page.set_rack_session(author_id: author.id)
      visit edit_author_path

      expect(page).to have_content('Edit Author')
      fill_in('Name', with: 'a-new-name')
      click_on 'Update Author'

      expect(page).to have_content('Author was successfully updated.')
      expect(page).to have_content('a-new-name')
    end
  end

  context 'when given an invalid name' do
    scenario 'fails to update' do
      page.set_rack_session(author_id: author.id)
      visit edit_author_path

      expect(page).to have_content('Edit Author')
      fill_in('Name', with: 'invalid_name')
      click_on 'Update Author'

      expect(page).to have_content('Name can only contain alphanumeric characters and dashes')
      expect(page).to have_current_path(edit_author_path)
    end
  end
end
