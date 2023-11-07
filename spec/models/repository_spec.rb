require 'rails_helper'

RSpec.describe Repository do
  describe '#valid?' do
    it 'returns false when given an invalid name' do
      repo = build(:repository, name: 'repo?name')
      expect(repo.valid?).to be false
    end

    it 'returns false when given an invalid token' do
      repo = build(:repository, token: 'invalid_token')
      expect(repo.valid?).to be false
    end

    it 'returns false when given an invalid branch' do
      repo = build(:repository, branch: 'invalid?branch')
      expect(repo.valid?).to be false
    end

    it 'returns false when given a name, but no token' do
      repo = build(:repository, name: 'repo_name', token: nil)
      expect(repo.valid?).to be false
    end

    it 'returns true when given a valid name, token and title, and associated author' do
      repo = build(:repository)
      expect(repo.valid?).to be true
    end

    it 'returns false when a repository with the same name exists for a given author' do
      first_repository = create(:repository)
      author = first_repository.author
      second_repo = build(:repository, author:)
      expect(second_repo.valid?).to be false
    end

    it 'returns true when a repository with the same name exists for another author' do
      create(:repository)
      second_author = create(:author, :real)
      second_repo = build(:repository, author: second_author)
      expect(second_repo.valid?).to be true
    end
  end

  describe '#set_git_url' do
    let(:repo) { create(:repository) }

    it 'returns the git_url created using Repository owner, name and token' do
      expect(repo.git_url).to eq('https://ghp_abcde12345@github.com/user/repo_name.git')
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

  describe '#generate_uuid' do
    let(:repo) { create(:repository) }

    it 'generates a uuid when a record is created' do
      expect(repo.uuid).not_to be_nil
    end
  end
end
