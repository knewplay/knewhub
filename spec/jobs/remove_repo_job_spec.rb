require 'rails_helper'

RSpec.describe RemoveRepoJob, type: :job do
  let(:repo) { create(:repository, :real, hook_id: 436_760_769) }
  let(:client) { Octokit::Client.new(access_token: repo.token) }

  it 'queues the job' do
    RemoveRepoJob.perform_async(repo.id)
    expect(RemoveRepoJob).to have_enqueued_sidekiq_job(repo.id)
  end

  context 'when executing perform' do
    before do
      VCR.use_cassette('remove_repo') do
        Sidekiq::Testing.inline! do
          RemoveRepoJob.perform_async(repo.id)
        end
      end
    end

    it 'removes the webhook' do
      VCR.use_cassette('get_repo_webhooks') do
        get_repo_hooks = client.hooks("#{repo.author.github_username}/#{repo.name}")
        expect(get_repo_hooks).to eq([])
      end
    end

    it 'removes the record from the database' do
      expect(Repository.exists?(repo.id)).to be false
    end
  end
end
