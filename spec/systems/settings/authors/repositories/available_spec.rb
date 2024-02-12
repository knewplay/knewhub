require 'rails_helper'

RSpec.describe 'Settings::Authors::Repositories#index', type: :system do
  let(:author) { create(:author, :real) }

  context 'when an author has not added repositories' do
    before do
      sign_in author.user
      VCR.use_cassettes([{ name: 'get_installation_access_token' }, { name: 'get_repos' }]) do
        visit available_settings_author_repositories_path
      end
    end

    it 'lists repositories that the author has allowed access to' do
      expect(page).to have_content('Available Repositories')

      expect(page).to have_content('jp524/test-repo')
      expect(page).to have_content('jp524/book-programming-essential')
    end
  end

  context 'when an author has added a repository' do
    before do
      sign_in author.user
      create(:repository, author:, owner: 'jp524', name: 'test-repo')
      VCR.use_cassettes([{ name: 'get_installation_access_token' }, { name: 'get_repos' }]) do
        visit available_settings_author_repositories_path
      end
    end

    it 'lists only the repositories that remain to be added' do
      expect(page).to have_no_content('jp524/test-repo')
      expect(page).to have_content('jp524/book-programming-essential')
    end
  end
end
