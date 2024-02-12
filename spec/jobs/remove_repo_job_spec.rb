require 'rails_helper'

RSpec.describe RemoveRepoJob do
  let!(:repo) { create(:repository, :real, hook_id: 460_475_619) }
  let!(:author) { repo.author }

  it 'queues the job' do
    described_class.perform_async(author.id, repo.full_name, repo.hook_id)
    expect(described_class).to have_enqueued_sidekiq_job(
      author.id,
      repo.full_name,
      repo.hook_id
    )
  end

  context 'when executing perform' do
    before do
      VCR.use_cassettes([{ name: 'get_installation_access_token' }, { name: 'delete_github_webhook' }]) do
        Sidekiq::Testing.inline! do
          described_class.perform_async(author.id, repo.full_name, repo.hook_id)
        end
      end
    end

    it 'removes the webhook' do
      VCR.use_cassettes([{ name: 'get_installation_access_token' }, { name: 'get_repo_webhooks' }]) do
        get_repo_hooks = author.github_client.hooks(repo.full_name)
        expect(get_repo_hooks).to eq([])
      end
    end

    it 'does not removes the record from the database' do
      expect(Repository.exists?(repo.id)).to be true
    end
  end
end
