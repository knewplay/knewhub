require 'rails_helper'

RSpec.describe Repository do
  describe '#valid?' do
    it 'returns false when given an invalid name' do
      repo = build(:repository, name: 'repo?name')
      expect(repo.valid?).to be false
    end

    it 'returns false when given an invalid branch' do
      repo = build(:repository, branch: 'invalid?branch')
      expect(repo.valid?).to be false
    end

    it 'returns true when given a valid name, title, and associated author' do
      repo = build(:repository)
      expect(repo.valid?).to be true
    end

    it 'returns false when a repository with the same name exists for a given github_installation' do
      first_repo = create(:repository)
      github_installation = first_repo.github_installation
      second_repo = build(:repository, github_installation:)
      expect(second_repo.valid?).to be false
    end

    it 'returns true when a repository with the same name exists for another github_installation' do
      create(:repository)
      second_github_installation = create(:github_installation, :real)
      second_repo = build(:repository, github_installation: second_github_installation)
      expect(second_repo.valid?).to be true
    end
  end

  describe '#git_url' do
    let(:repo) { create(:repository) }
    let(:github_installation) { repo.github_installation }

    it "returns the git_url created using Repository owner, name and Author's access token" do
      allow(github_installation).to receive(:access_token).and_return('ghs_abcde12345')
      expect(repo.git_url).to eq('https://x-access-token:ghs_abcde12345@github.com/user/repo_name.git')
    end
  end

  describe '#set_branch' do
    let(:repo) { build(:repository) }

    it 'branch is "main" if not specified' do
      repo.save
      expect(repo.branch).to eq('main')
    end

    it 'branch is as specified' do
      repo.branch = 'some_branch'
      repo.save
      expect(repo.branch).to eq('some_branch')
    end
  end
end
