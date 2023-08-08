require 'rails_helper'

RSpec.describe PullGithubRepoJob, type: :job do
  before(:all) do
    Repository.delete_all
    Author.delete_all
    author = Author.create(github_uid: '85654561', github_username: 'jp524')
    @repo = Repository.create(name: 'test-repo', token: Rails.application.credentials.pat, author:, title: 'Test Repo')
  end

  it 'queues the job' do
    PullGithubRepoJob.perform_async(@repo.id)
    expect(PullGithubRepoJob).to have_enqueued_sidekiq_job(@repo.id)
  end

  it 'executes perform' do
    Sidekiq::Testing.inline! do
      last_pull_at = @repo.last_pull_at

      VCR.use_cassette('pull_github_repo') do
        PullGithubRepoJob.perform_async(@repo.id)
      end
      @repo.reload

      expect(@repo.last_pull_at).not_to eq(last_pull_at)
    end
  end
end
