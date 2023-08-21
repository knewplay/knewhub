require 'rails_helper'

RSpec.describe PullGithubRepoJob, type: :job do
  before(:all) do
    @repo = create(:repository, :real)
    Sidekiq::Testing.inline! do
      VCR.use_cassette('clone_github_repo') do
        CloneGithubRepoJob.perform_async(@repo.id)
      end
    end
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

  after(:all) do
    directory = Rails.root.join('repos', @repo.author.github_username, @repo.name)
    FileUtils.remove_dir(directory)
  end
end
