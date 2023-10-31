require 'rails_helper'

RSpec.describe RemoveRepoJob do
  let(:repo) { create(:repository, :real, hook_id: 436_760_769) }
  let(:client) { Octokit::Client.new(access_token: repo.token) }
  let(:github_username) { repo.author.github_username }
  let(:directory) { Rails.root.join('repos', github_username, repo.name).to_s }

  it 'queues the job' do
    described_class.perform_async(github_username, repo.name, repo.hook_id, repo.token, directory)
    expect(described_class).to have_enqueued_sidekiq_job(
      github_username,
      repo.name,
      repo.hook_id,
      repo.token,
      directory
    )
  end

  context 'when executing perform' do
    before do
      VCR.use_cassette('remove_repo') do
        Sidekiq::Testing.inline! do
          described_class.perform_async(github_username, repo.name, repo.hook_id, repo.token, directory)
        end
      end
    end

    it 'removes the webhook' do
      VCR.use_cassette('get_repo_webhooks') do
        get_repo_hooks = client.hooks("#{github_username}/#{repo.name}")
        expect(get_repo_hooks).to eq([])
      end
    end

    it 'does not removes the record from the database' do
      expect(Repository.exists?(repo.id)).to be true
    end
  end
end
