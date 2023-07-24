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

    it 'returns false when given an invalid branch' do
      repo = Repository.new(owner: 'owner', name: 'repo_name', branch: 'invalid?branch')
      expect(repo.valid?).to be false
    end

    it 'returns false when given a valid owner and name, but no token' do
      repo = Repository.new(owner: 'owner', name: 'repo_name')
      expect(repo.valid?).to be false
    end

    it 'returns true when given a valid owner, name and token' do
      repo = Repository.new(owner: 'owner', name: 'repo_name', token: 'ghp_abde12345')
      expect(repo.valid?).to be true
    end
  end

  describe '#set_git_url' do
    let(:repo) { described_class.create(owner: 'user', name: 'repo_name', token: 'ghp_abde12345') }

    it 'returns the git_url created using Repository owner, name and token' do
      expect(repo.git_url).to eq('https://ghp_abde12345@github.com/user/repo_name.git')
    end
  end

  describe '#set_branch' do
    let(:repo) { described_class.new(owner: 'user', name: 'repo_name', token: 'ghp_abde12345') }

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

  describe '#generate_uuid' do
    let(:repo) { described_class.create(owner: 'user', name: 'repo_name', token: 'ghp_abde12345') }

    it 'generates a uuid when a record is created' do
      expect(repo.uuid).not_to be_nil
    end
  end
end
