require 'rails_helper'

RSpec.describe CreateGithubWebhookJob do
  let(:repo) { create(:repository, :real, uuid: '42b189e0-5d63-4529-b863-198a9c259669') }
  let(:build) { create(:build, repository: repo, aasm_state: :creating_webhook) }

  it 'queues the job' do
    described_class.perform_async(build.id)
    expect(described_class).to have_enqueued_sidekiq_job(build.id)
  end

  context 'when executing perform' do
    after do
      VCR.use_cassette('delete_github_webhook') do
        client = Octokit::Client.new(access_token: repo.token)
        client.remove_hook("#{repo.author.github_username}/#{repo.name}", 436_588_649)
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
