require 'rails_helper'

RSpec.describe PullGithubRepoJob, type: :job do
  before(:all) do
    Repository.delete_all
    Author.delete_all
    author = Author.create(github_uid: '85654561', github_username: 'jp524')
    @repo = Repository.create(name: 'test-repo', token: Rails.application.credentials.pat, author:)
  end

  it 'queues the job' do
    PullGithubRepoJob.perform_async(@repo.uuid, @repo.name, @repo.author.github_username, @repo.description)
    expect(PullGithubRepoJob).to have_enqueued_sidekiq_job(
      @repo.uuid,
      @repo.name,
      @repo.author.github_username,
      @repo.description
    )
  end

  it 'executes perform when webhook_name == name && webhook_owner == repository.author.github_username' do
    Sidekiq::Testing.inline! do
      expect(@repo.description).to be_nil
      expect(@repo.last_pull_at).to be_nil

      PullGithubRepoJob.perform_async(@repo.uuid, @repo.name, @repo.author.github_username, @repo.description)
      @repo.reload

      expect(@repo.last_pull_at).not_to be_nil
    end
  end

  it 'executes perform when webhook_name != name && webhook_owner == repository.author.github_username' do
    Sidekiq::Testing.inline! do
      expect(@repo.last_pull_at).not_to be_nil

      PullGithubRepoJob.perform_async(@repo.uuid, 'markdown-templates', @repo.author.github_username, 'The description')
      @repo.reload

      expect(@repo.last_pull_at).not_to be_nil
      expect(@repo.name).to eq('markdown-templates')
      expect(@repo.description).to eq('The description')
    end
  end
end
