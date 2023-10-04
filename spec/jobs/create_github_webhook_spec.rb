require 'rails_helper'

RSpec.describe CreateGithubWebhookJob, type: :job do
  let(:repo) { create(:repository, :real, uuid: '42b189e0-5d63-4529-b863-198a9c259669') }
  let(:build) { create(:build, repository: repo, aasm_state: :creating_webhook) }

  it 'queues the job' do
    CreateGithubWebhookJob.perform_async(repo.id, build.id)
    expect(CreateGithubWebhookJob).to have_enqueued_sidekiq_job(repo.id, build.id)
  end

  it 'executes perform' do
    expect(repo.description).to be_nil
    expect(repo.last_pull_at).to be_nil
    VCR.use_cassette('create_github_webhook') do
      Sidekiq::Testing.inline! do
        CreateGithubWebhookJob.perform_async(repo.id, build.id)
      end
    end

    VCR.use_cassette('delete_github_webhook') do
      client = Octokit::Client.new(access_token: repo.token)
      client.remove_hook("#{repo.author.github_username}/#{repo.name}", '436588649')
    end
  end
end
