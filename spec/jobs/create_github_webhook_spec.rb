require 'rails_helper'

RSpec.describe CreateGithubWebhookJob, type: :job do
  before(:all) do
    @repo = Repository.create(owner: 'jp524', name: 'markdown-templates', token: Rails.application.credentials.pat)
  end

  it 'queues the job' do
    CreateGithubWebhookJob.perform_async(@repo.uuid,@repo.name, @repo.owner, @repo.token)
    expect(CreateGithubWebhookJob).to have_enqueued_sidekiq_job(@repo.uuid,@repo.name, @repo.owner, @repo.token)
  end

  it 'executes perform' do
    Sidekiq::Testing.inline! do
      expect(@repo.description).to be_nil
      expect(@repo.last_pull_at).to be_nil
      CreateGithubWebhookJob.perform_async(@repo.uuid, @repo.name, @repo.owner, @repo.token)
    end
  end
end
