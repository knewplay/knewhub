require 'rails_helper'

RSpec.describe PullGithubRepoJob, type: :job do
  include ActiveJob::TestHelper

  before(:all) do
    @repo = Repository.create(owner: 'jp524', name: 'markdown-templates', token: Rails.application.credentials.pat)
  end

  subject(:job) { described_class.perform_later(@repo) }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'executes perform' do
    expect(@repo.description).to be_nil
    expect(@repo.last_pull_at).to be_nil

    perform_enqueued_jobs { job }
    @repo.reload

    expect(@repo.description).to eq('Files templates for testing')
    expect(@repo.last_pull_at).not_to be_nil
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
