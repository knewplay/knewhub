require 'rails_helper'

RSpec.describe 'Settings::Authors::Repositories#index', type: :system do
  let(:repo) { create(:repository) }
  let(:author) { repo.author }
  let(:repo_from_other_author) { create(:repository, :real) }

  context 'when signed in as an author' do
    it "displays author's repositories" do
      sign_in author.user
      page.set_rack_session(author_id: author.id)

      visit settings_author_repositories_path
      expect(page).to have_content("#{author.name}'s Repositories")
      expect(page).to have_content(repo.name)
    end

    it 'does not display repositories by other authors' do
      sign_in author.user
      page.set_rack_session(author_id: author.id)

      visit settings_author_repositories_path
      expect(page).to have_no_content(repo_from_other_author.name)
    end
  end

  context 'when not signed in as an author' do
    it 'redirects to root path' do
      visit settings_author_repositories_path

      expect(page).to have_current_path(root_path)
      expect(page).to have_content('Please link your GitHub account.')
    end
  end
end
