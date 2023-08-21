require 'rails_helper'

RSpec.describe CloneGithubRepoJob, type: :job do
  before(:all) do
    @repo = create(:repository, :real)
  end

  it 'queues the job' do
    CloneGithubRepoJob.perform_async(@repo.id)
    expect(CloneGithubRepoJob).to have_enqueued_sidekiq_job(@repo.id)
  end

  it 'executes perform' do
    Sidekiq::Testing.inline! do
      expect(@repo.description).to be_nil
      expect(@repo.last_pull_at).to be_nil

      VCR.use_cassette('clone_github_repo') do
        CloneGithubRepoJob.perform_async(@repo.id)
      end
      @repo.reload

      expect(@repo.description).not_to be_nil
      expect(@repo.last_pull_at).not_to be_nil
    end
  end

  after(:all) do
    directory = Rails.root.join('repos', @repo.author.github_username, @repo.name)
    FileUtils.remove_dir(directory)
  end
end
