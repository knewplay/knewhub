require 'rails_helper'

RSpec.describe CreateGithubWebhookJob do
  let(:repo) { create(:repository, :real, uuid: '397df2f0-489b-4d9a-8725-476ebee3b49b') }
  let(:build) { create(:build, repository: repo, aasm_state: :creating_webhook) }

  it 'queues the job' do
    described_class.perform_async(build.id)
    expect(described_class).to have_enqueued_sidekiq_job(build.id)
  end

  context 'when executing perform' do
    after do
      VCR.use_cassette('delete_github_webhook') do
        repo.author.github_client.remove_hook(repo.full_name, 460_475_619)
      end
    end

    it 'creates the webhook' do
      expect(repo.description).to be_nil
      expect(repo.last_pull_at).to be_nil
      VCR.use_cassette('create_github_webhook') do
        Sidekiq::Testing.inline! do
          described_class.perform_async(build.id)
        end
      end
    end
  end
end
