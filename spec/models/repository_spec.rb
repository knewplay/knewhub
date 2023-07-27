require 'rails_helper'

RSpec.describe Repository, type: :model do
  describe '#valid?' do
    it 'returns false when given an invalid name' do
      repo = Repository.new(name: 'repo?name')
      expect(repo.valid?).to be false
    end

    it 'returns false when given an invalid token' do
      repo = Repository.new(name: 'repo_name', token: 'invalid_token')
      expect(repo.valid?).to be false
    end

    it 'returns false when given an invalid branch' do
      repo = Repository.new(name: 'repo_name', branch: 'invalid?branch')
      expect(repo.valid?).to be false
    end

    it 'returns false when given a and name, but no token' do
      repo = Repository.new(name: 'repo_name')
      expect(repo.valid?).to be false
    end

    it 'returns true when given a valid name and token, and associated author' do
      repo = Repository.new(name: 'repo_name', token: 'ghp_abde12345')
      author = Author.create(github_uid: '12345', github_username: 'user')
      repo.author = author
      repo.save
      expect(repo.valid?).to be true
    end
  end

  describe '#set_git_url' do
    before do
      author = Author.create(github_uid: '12345', github_username: 'user')
      @repo = described_class.create(name: 'repo_name', token: 'ghp_abde12345', author:)
    end

    it 'returns the git_url created using Repository owner, name and token' do
      expect(@repo.git_url).to eq('https://ghp_abde12345@github.com/user/repo_name.git')
    end
  end

  describe '#set_branch' do
    before do
      author = Author.create(github_uid: '12345', github_username: 'user')
      @repo = described_class.new(name: 'repo_name', token: 'ghp_abde12345', author:)
    end

    it 'branch is "main" if not specified' do
      @repo.save
      expect(@repo.branch).to eq('main')
    end

    it 'branch is as specified' do
      @repo.branch = 'some_branch'
      @repo.save
      expect(@repo.branch).to eq('some_branch')
    end
  end

  describe '#generate_uuid' do
    before do
      author = Author.create(github_uid: '12345', github_username: 'user')
      @repo = described_class.create(name: 'repo_name', token: 'ghp_abde12345', author:)
    end

    it 'generates a uuid when a record is created' do
      expect(@repo.uuid).not_to be_nil
    end
  end
end
