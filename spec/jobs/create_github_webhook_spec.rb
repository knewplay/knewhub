require 'rails_helper'

RSpec.describe CreateGithubWebhookJob, type: :job do
  let(:repo) { create(:repository, :real) }
  let(:build) { create(:build, repository: repo) }

  it 'queues the job' do
    CreateGithubWebhookJob.perform_async(repo.id, build.id)
    expect(CreateGithubWebhookJob).to have_enqueued_sidekiq_job(repo.id, build.id)
  end

  it 'executes perform' do
    VCR.use_cassette('create_github_webhook') do
      Sidekiq::Testing.inline! do
        expect(repo.description).to be_nil
        expect(repo.last_pull_at).to be_nil
        CreateGithubWebhookJob.perform_async(repo.id, build.id)
      end
    end
  end
end
