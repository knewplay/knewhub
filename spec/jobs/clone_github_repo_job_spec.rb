require 'rails_helper'

RSpec.describe CloneGithubRepoJob do
  before(:all) do
    # HTTP request required to clone repository using Octokit client
    VCR.turn_off!
    WebMock.allow_net_connect!
    @repo = create(:repository, :real)
    @build = create(:build, repository: @repo, aasm_state: :cloning_repo)
  end

  after(:all) do
    FileUtils.remove_dir(@repo.storage_path)
    VCR.turn_on!
    WebMock.disable_net_connect!
  end

  it 'queues the job' do
    described_class.perform_async(@build.id)
    expect(described_class).to have_enqueued_sidekiq_job(@build.id)
  end

  it 'executes perform' do
    expect(@repo.last_pull_at).to be_nil
    Sidekiq::Testing.inline! do
      described_class.perform_async(@build.id)
    end
    @repo.reload
    expect(@repo.last_pull_at).not_to be_nil
  end
end
