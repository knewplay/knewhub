require 'rails_helper'

RSpec.describe GithubInstallation do
  describe '#valid?' do
    let(:github_installation) { build(:github_installation) }

    it 'returns false when not associated with an Author' do
      github_installation.author = nil
      expect(github_installation).not_to be_valid
    end

    it 'returns false when installation_id is nil' do
      github_installation.installation_id = nil
      expect(github_installation).not_to be_valid
    end

    it 'returns true when associated with an Author and having an installation_id' do
      expect(github_installation).to be_valid
    end
  end

  describe '#list_github_repositories' do
    let(:github_installation) { create(:github_installation, :real) }

    it 'returns the full_name of repositories available for the Installation' do
      result = ['jp524/test-repo', 'jp524/book-programming-essential']
      VCR.use_cassettes([{ name: 'get_installation_access_token' }, { name: 'get_repos' }]) do
        expect(github_installation.list_github_repositories).to eq(result)
      end
    end
  end

  describe '#repositories_available_for_addition' do
    let!(:github_installation) { create(:github_installation, :real) }

    before do
      create(:repository, :real, github_installation:)
    end

    it 'returns the full_name of repositories that can be added' do
      result = ['jp524/book-programming-essential']
      VCR.use_cassettes([{ name: 'get_installation_access_token' }, { name: 'get_repos' }]) do
        expect(github_installation.repositories_available_for_addition).to eq(result)
      end
    end
  end
end
