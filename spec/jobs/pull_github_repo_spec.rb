require 'rails_helper'

RSpec.describe PullGithubRepoJob, type: :job do
  before(:all) do
    Repository.delete_all
    @repo = Repository.create(owner: 'jp524', name: 'markdown-templates', token: Rails.application.credentials.pat)
  end

  it 'queues the job' do
    PullGithubRepoJob.perform_async(@repo.name, @repo.owner)
    expect(PullGithubRepoJob).to have_enqueued_sidekiq_job(@repo.name, @repo.owner)
  end

  it 'executes perform' do
    Sidekiq::Testing.inline! do
      expect(@repo.description).to be_nil
      expect(@repo.last_pull_at).to be_nil

      PullGithubRepoJob.perform_async(@repo.name, @repo.owner)
      @repo.reload

      expect(@repo.description).to eq('Files templates for testing')
      expect(@repo.last_pull_at).not_to be_nil
    end
  end
end
