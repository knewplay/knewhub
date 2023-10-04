require 'rails_helper'

RSpec.describe PullGithubRepoJob, type: :job do
  before(:all) do
    @repo = create(:repository, :real)
    clone_build = create(:build, repository: @repo, aasm_state: :cloning_repo)
    @pull_build = create(:build, repository: @repo, aasm_state: :pulling_repo)
    Sidekiq::Testing.inline! do
      VCR.use_cassette('clone_github_repo') do
        CloneGithubRepoJob.perform_async(@repo.id, clone_build.id)
      end
    end
  end

  it 'queues the job' do
    PullGithubRepoJob.perform_async(@repo.id, @pull_build.id)
    expect(PullGithubRepoJob).to have_enqueued_sidekiq_job(@repo.id, @pull_build.id)
  end

  it 'executes perform' do
    last_pull_at = @repo.last_pull_at
    Sidekiq::Testing.inline! do
      VCR.use_cassette('pull_github_repo') do
        PullGithubRepoJob.perform_async(@repo.id, @pull_build.id)
      end
    end
    @repo.reload
    expect(@repo.last_pull_at).not_to eq(last_pull_at)
  end

  after(:all) do
    directory = Rails.root.join('repos', @repo.author.github_username, @repo.name)
    FileUtils.remove_dir(directory)
  end
end
