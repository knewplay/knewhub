require 'rails_helper'

RSpec.describe 'AuthorSpace::Repositories #index', type: :system do
  let(:repo) { create(:repository) }
  let(:author) { repo.author }
  let(:repo_from_other_author) { create(:repository, :real) }

  context 'when signed in as an author' do
    scenario "displays author's repositories" do
      page.set_rack_session(author_id: author.id)

      visit settings_author_repositories_path
      expect(page).to have_content("#{author.name}'s Repositories")
      expect(page).to have_content(repo.name)
    end

    scenario 'does not display repositories by other authors' do
      page.set_rack_session(author_id: author.id)

      visit settings_author_repositories_path
      expect(page).not_to have_content(repo_from_other_author.name)
    end
  end

  context 'when not signed in as an author' do
    scenario 'redirects to root path' do
      visit settings_author_repositories_path

      expect(page).to have_current_path(root_path)
      expect(page).to have_content('Please sign in with GitHub.')
    end
  end
end
