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

    it 'returns the full_name and uid of repositories available for the Installation' do
      result = [{ full_name: 'jp524/test-repo', uid: 663_068_537 },
                { full_name: 'jp524/book-programming-essential', uid: 696_415_885 }]
      VCR.use_cassettes([{ name: 'get_installation_access_token' }, { name: 'get_repos' }]) do
        expect(github_installation.list_github_repositories).to eq(result)
      end
    end
  end

  describe '#already_added_repositories' do
    let!(:github_installation) { create(:github_installation, :real) }

    before do
      create(:repository, :real, github_installation:)
    end

    it 'returns uid of repositories that have already been added' do
      result = [663_068_537]
      VCR.use_cassettes([{ name: 'get_installation_access_token' }, { name: 'get_repos' }]) do
        expect(github_installation.already_added_repositories).to eq(result)
      end
    end
  end

  describe '#repositories_available_for_addition' do
    let!(:github_installation) { create(:github_installation, :real) }

    before do
      create(:repository, :real, github_installation:)
    end

    it 'returns the full_name and uid of repositories that can be added' do
      result = [{ full_name: 'jp524/book-programming-essential', uid: 696_415_885 }]
      VCR.use_cassettes([{ name: 'get_installation_access_token' }, { name: 'get_repos' }]) do
        expect(github_installation.repositories_available_for_addition).to eq(result)
      end
    end
  end
end
