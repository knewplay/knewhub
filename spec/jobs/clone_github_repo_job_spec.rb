require 'rails_helper'

RSpec.describe CloneGithubRepoJob do
  before(:all) do
    @repo = create(:repository, :real)
    @build = create(:build, repository: @repo, aasm_state: :cloning_repo)
  end

  after(:all) do
    FileUtils.remove_dir(@repo.storage_path)
  end

  it 'queues the job' do
    described_class.perform_async(@build.id)
    expect(described_class).to have_enqueued_sidekiq_job(@build.id)
  end

  it 'executes perform' do
    expect(@repo.last_pull_at).to be_nil
    Sidekiq::Testing.inline! do
      VCR.use_cassette('get_installation_access_token') do
        described_class.perform_async(@build.id)
      end
    end
    git_clone(@repo)
    @repo.reload
    expect(@repo.last_pull_at).not_to be_nil
  end
end
