require 'rails_helper'

RSpec.describe CloneGithubRepoJob, type: :job do
  before(:all) do
    Repository.delete_all
    Author.delete_all
    author = Author.create(github_uid: '85654561', github_username: 'jp524')
    @repo = Repository.create(name: 'test-repo', token: Rails.application.credentials.pat, author:)
  end

  it 'queues the job' do
    CloneGithubRepoJob.perform_async(@repo.id)
    expect(CloneGithubRepoJob).to have_enqueued_sidekiq_job(@repo.id)
  end

  it 'executes perform' do
    Sidekiq::Testing.inline! do
      expect(@repo.description).to be_nil
      expect(@repo.last_pull_at).to be_nil

      CloneGithubRepoJob.perform_async(@repo.id)
      @repo.reload

      expect(@repo.description).not_to be_nil
      expect(@repo.last_pull_at).not_to be_nil
    end
  end
end
