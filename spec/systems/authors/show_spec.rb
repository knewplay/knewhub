require 'rails_helper'

RSpec.describe 'Author #show', type: :system do
  let(:author) { create(:author) }

  context 'when signed in as an author' do
    scenario 'displays information about current author' do
      page.set_rack_session(author_id: author.id)

      visit author_path
      expect(page).to have_content(author.name)
      expect(page).to have_content(author.github_username)
    end
  end

  context 'when not signed in as an author' do
    scenario 'redirects to root path' do
      visit author_path

      expect(page).to have_current_path(root_path)
      expect(page).to have_content('Please sign in with GitHub.')
    end
  end
end
