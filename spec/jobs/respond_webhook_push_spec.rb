require 'rails_helper'

RSpec.describe RespondWebhookPushJob, type: :job do
  before(:all) do
    @repo = create(:repository, :real)
    clone_build = create(:build, repository: @repo, aasm_state: :cloning_repo)
    @build = create(:build, action: 'webhook_push', repository: @repo, aasm_state: :receiving_webhook)
    Sidekiq::Testing.inline! do
      VCR.use_cassette('clone_github_repo') do
        CloneGithubRepoJob.perform_async(@repo.id, clone_build.id)
      end
    end
  end

  it 'queues the job' do
    RespondWebhookPushJob.perform_async(
      @build.id,
      @repo.uuid,
      @repo.name,
      @repo.author.github_username,
      @repo.description
    )
    expect(RespondWebhookPushJob).to have_enqueued_sidekiq_job(
      @build.id,
      @repo.uuid,
      @repo.name,
      @repo.author.github_username,
      @repo.description
    )
  end

  context 'executes perform' do
    it 'when webhook_name == name && webhook_owner == repository.author.github_username' do
      Sidekiq::Testing.inline! do
        RespondWebhookPushJob.perform_async(
          @build.id,
          @repo.uuid,
          @repo.name,
          @repo.author.github_username,
          @repo.description
        )
        @repo.reload

        expect(@repo.last_pull_at).not_to be_nil
      end
    end

    it 'when webhook_name != name && webhook_owner == repository.author.github_username' do
      Sidekiq::Testing.inline! do
        RespondWebhookPushJob.perform_async(
          @build.id,
          @repo.uuid, 'markdown-templates',
          @repo.author.github_username,
          'The description has changed'
        )
        @repo.reload

        expect(@repo.last_pull_at).not_to be_nil
        expect(@repo.name).to eq('markdown-templates')
        expect(@repo.description).to eq('The description has changed')
      end
    end
  end

  after(:all) do
    directory = Rails.root.join('repos', @repo.author.github_username, @repo.name)
    FileUtils.remove_dir(directory)
  end
end
