require 'rails_helper'

RSpec.describe RespondWebhookPushJob do
  before(:all) do
    @repo = create(:repository, :real)
    @build = create(:build, action: 'webhook_push', repository: @repo, aasm_state: :receiving_webhook)
    git_clone(@repo)
  end

  after(:all) do
    FileUtils.remove_dir(@repo.storage_path)
  end

  it 'queues the job' do
    described_class.perform_async(
      @build.id,
      @repo.uid,
      @repo.description
    )
    expect(described_class).to have_enqueued_sidekiq_job(
      @build.id,
      @repo.uid,
      @repo.description
    )
  end

  context 'when executing perform' do
    it 'updates the repository description' do
      Sidekiq::Testing.inline! do
        described_class.perform_async(
          @build.id,
          @repo.uid,
          'The description has changed'
        )
        @repo.reload

        expect(@repo.last_pull_at).not_to be_nil
        expect(@repo.description).to eq('The description has changed')
      end
    end
  end
end
