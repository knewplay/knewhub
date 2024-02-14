require 'rails_helper'

RSpec.describe CreateGithubWebhookJob do
  let(:repo) { create(:repository, :real) }
  let(:build) { create(:build, repository: repo, aasm_state: :creating_webhook) }

  it 'queues the job' do
    described_class.perform_async(build.id)
    expect(described_class).to have_enqueued_sidekiq_job(build.id)
  end

  context 'when executing perform' do
    after do
      VCR.use_cassettes([{ name: 'get_installation_access_token' }, { name: 'delete_github_webhook' }]) do
        repo.github_installation.github_client.remove_hook(repo.full_name, 460_475_619)
      end
    end

    it 'creates the webhook' do
      expect(repo.description).to be_nil
      expect(repo.last_pull_at).to be_nil
      VCR.use_cassettes([{ name: 'get_installation_access_token', options: { allow_playback_repeats: true } },
                         { name: 'create_github_webhook' },
                         { name: 'test_github_webhook' }]) do
        Sidekiq::Testing.inline! do
          described_class.perform_async(build.id)
        end
      end
    end
  end
end
