require 'rails_helper'

RSpec.describe CreateGithubWebhookJob, type: :job do
  let(:repo) { create(:repository, :real, uuid: 'c3a3bf52-f983-4b1a-847a-be921fa97914') }
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

    log_content = build.logs.first.content
    hook_id = log_content.match(/Hook ID: (\d+)/)[1].to_i

    VCR.use_cassette('delete_github_webhook') do
      client = Octokit::Client.new(access_token: repo.token)
      client.remove_hook("#{repo.author.github_username}/#{repo.name}", hook_id)
    end
  end
end
