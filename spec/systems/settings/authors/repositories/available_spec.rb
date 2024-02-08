require 'rails_helper'

RSpec.describe 'Settings::Authors::Repositories#index', type: :system do
  let(:author) { create(:author, :real) }

  context 'when signed in as an author' do
    before do
      sign_in author.user
      VCR.use_cassette('available_repositories') do
        visit available_settings_author_repositories_path
      end
    end

    it 'lists repositories that the author has allowed access to' do
      expect(page).to have_content('Available Repositories')

      expect(page).to have_content('jp524/test-repo')
      expect(page).to have_content('jp524/book-programming-essential')
    end
  end
end
