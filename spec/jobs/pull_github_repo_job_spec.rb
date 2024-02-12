require 'rails_helper'

RSpec.describe PullGithubRepoJob do
  before(:all) do
    # HTTP request required to clone repository using Octokit client
    VCR.turn_off!
    WebMock.allow_net_connect!
    @repo = create(:repository, :real)
    clone_build = create(:build, repository: @repo, aasm_state: :cloning_repo)
    @pull_build = create(:build, repository: @repo, aasm_state: :pulling_repo)
    Sidekiq::Testing.inline! do
      CloneGithubRepoJob.perform_async(clone_build.id)
    end
    VCR.turn_on!
    WebMock.disable_net_connect!
  end

  after(:all) do
    directory = Rails.root.join('repos', @repo.full_name)
    FileUtils.remove_dir(directory)
  end

  it 'queues the job' do
    described_class.perform_async(@pull_build.id)
    expect(described_class).to have_enqueued_sidekiq_job(@pull_build.id)
  end

  it 'executes perform' do
    last_pull_at = @repo.last_pull_at
    Sidekiq::Testing.inline! do
      VCR.use_cassette('pull_github_repo') do
        described_class.perform_async(@pull_build.id)
      end
    end
    @repo.reload
    expect(@repo.last_pull_at).not_to eq(last_pull_at)
  end
end
