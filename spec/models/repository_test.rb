require 'rails_helper'

RSpec.describe Repository, type: :model do
  describe '#valid?' do
    it 'returns false when given an invalid owner' do
      repo = Repository.new(owner: 'invalid.owner', name: 'repo_name')
      expect(repo.valid?).to be false
    end

    it 'returns false when given an invalid name' do
      repo = Repository.new(owner: 'owner', name: 'repo?name')
      expect(repo.valid?).to be false
    end

    it 'returns false when given an invalid token' do
      repo = Repository.new(owner: 'owner', name: 'repo_name', token: 'invalid_token')
      expect(repo.valid?).to be false
    end

    it 'returns true when given a valid owner and name' do
      repo = Repository.new(owner: 'owner', name: 'repo_name')
      expect(repo.valid?).to be true
    end

    it 'returns true when given a valid owner, name and token' do
      repo = Repository.new(owner: 'owner', name: 'repo_name', token: 'ghp_abde12345')
      expect(repo.valid?).to be true
    end
  end

  describe '#set_git_url' do
    let(:repo) { described_class.create(owner: 'user', name: 'repo_name') }

    it 'returns the git_url created using Repository owner and name' do
      expect(repo.git_url).to eq('https://github.com/user/repo_name.git')
    end

    it 'returns the git_url created using Repository owner, name and token' do
      repo.token = 'ghp_abde12345'
      repo.save
      expect(repo.git_url).to eq('https://ghp_abde12345@github.com/user/repo_name.git')
    end
  end
end
