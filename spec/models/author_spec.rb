require 'rails_helper'

RSpec.describe Author do
  describe '#set_name' do
    let(:author) { create(:author, github_username: 'user') }

    it "uses the 'github_username'" do
      expect(author.name).to eq(author.github_username)
    end
  end

  describe '#list_github_repositories' do
    let!(:author) { create(:author, :real) }

    before do
      create(:github_installation, :real, author:)
      create(:github_installation, :real_additional, author:)
    end

    it 'returns the full_name of repositories available for the Installation' do
      result = [{ full_name: 'jp524/markdown-templates', uid: 656_764_501 },
                { full_name: 'jp524/test-repo', uid: 663_068_537 },
                { full_name: 'jp524/book-programming-essential', uid: 696_415_885 },
                { full_name: 'knewplay/book-programming-essential', uid: 635_362_242 },
                { full_name: 'knewplay/vex-robotics-programming-with-c', uid: 660_263_073 },
                { full_name: 'knewplay/course-vex-vrc-in-c', uid: 704_073_409 }]
      VCR.use_cassettes([{ name: 'get_installation_access_token' },
                         { name: 'get_installation_access_token_additional' },
                         { name: 'get_repos_multiple_installations' }]) do
        expect(author.list_github_repositories).to eq(result)
      end
    end
  end

  describe '#repositories_available_for_addition' do
    let!(:author) { create(:author, :real) }

    before do
      github_installation = create(:github_installation, :real, author:)
      create(:github_installation, :real_additional, author:)
      create(:repository, :real, github_installation:)
    end

    it 'returns the full_name of repositories that can be added' do
      result = [{ full_name: 'jp524/markdown-templates', uid: 656_764_501 },
                { full_name: 'jp524/book-programming-essential', uid: 696_415_885 },
                { full_name: 'knewplay/book-programming-essential', uid: 635_362_242 },
                { full_name: 'knewplay/vex-robotics-programming-with-c', uid: 660_263_073 },
                { full_name: 'knewplay/course-vex-vrc-in-c', uid: 704_073_409 }]
      VCR.use_cassettes([{ name: 'get_installation_access_token' },
                         { name: 'get_installation_access_token_additional' },
                         { name: 'get_repos_multiple_installations' }]) do
        expect(author.repositories_available_for_addition).to eq(result)
      end
    end
  end
end
