require 'rails_helper'


RSpec.describe 'Settings::Authors::Repositories#index', type: :system do
  let!(:author) { create(:author, :real) }
  let!(:repo) { create(:repository, name: 'system-spec', author:) }
  let!(:repo_from_other_author) { create(:repository) }

  context 'when signed in as an author' do
    before do
      sign_in author.user
      VCR.use_cassette('available_repositories') do
        visit settings_author_repositories_path
      end
    end

    it "displays author's repositories" do
      expect(page).to have_content("#{author.name}'s Repositories")
      expect(page).to have_content(repo.name)
    end

    it 'does not display repositories by other authors' do
      expect(page).to have_no_content(repo_from_other_author.name)
    end

    it 'lists repositories that the author has allowed access to' do
      expect(page).to have_content('Add a new repository')

      expect(page).to have_content('jp524/test-repo')
      expect(page).to have_content('jp524/book-programming-essential')
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
