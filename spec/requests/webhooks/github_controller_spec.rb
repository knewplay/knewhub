require 'rails_helper'

describe Webhooks::GithubController do
  describe 'POST #create' do
    context "with a 'X-GitHub-Event: ping' event" do
      let(:repo) { create(:repository) }
      let(:secret) { Rails.application.credentials.webhook_secret }
      let(:data) { 'zen=Responsive+is+better+than+fast.' }
      let(:signature) { "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, data)}" }

      context 'when a valid request is received' do
        before do
          post "/webhooks/github/#{repo.uuid}",
               params: { 'zen': 'Responsive is better than fast.' },
               headers: { 'X-GitHub-Event': 'ping', 'X-Hub-Signature-256': signature }
        end

        scenario 'returns status 200' do
          expect(response.status).to eq(200)
        end

        scenario "creates a associated Build with the status 'Complete'" do
          expect(repo.builds.first.status).to eq('Complete')
        end

        scenario 'creates an associated Log with content' do
          expect(repo.builds.first.logs.first.content).to eq("GitHub webhook 'ping' received.")
        end
      end

      context 'when an invalid request is received' do
        before do
          post "/webhooks/github/#{repo.uuid}",
               params: { 'zen': 'Another message that will fail signature validation' },
               headers: {
                 'X-GitHub-Event': 'ping',
                 'X-Hub-Signature-256': signature
               }
        end

        scenario 'returns status 400' do
          expect(response.status).to eq(400)
        end

        scenario 'does not create an associated Build' do
          expect(repo.builds.first).to be_nil
        end
      end
    end

    context "with a 'X-GitHub-Event: push' event" do
      let(:repo) { create(:repository, :real, last_pull_at: DateTime.current) }
      let(:secret) { Rails.application.credentials.webhook_secret }
      let(:data) {
        'repository[name]=test-repo&repository[owner][name]=jp524&'\
        'repository[owner][id]=85654561&repository[description]=something'
      }
      let(:signature) { "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, data)}" }

      context 'when a valid request is received' do
        before do
          post "/webhooks/github/#{repo.uuid}",
               params: {
                 'repository': {
                   'name': 'test-repo',
                   'owner': {
                     'name': 'jp524',
                     'id': '85654561'
                   },
                   'description': 'something'
                 }
               },
               headers: {
                 'X-GitHub-Event': 'push',
                 'X-Hub-Signature-256': signature
               }
        end

        scenario 'returns status 200' do
          expect(response.status).to eq(200)
        end

        scenario 'enqueues background job' do
          expect(RespondWebhookPushJob).to have_enqueued_sidekiq_job(
            repo.builds.first.id,
            repo.uuid,
            'test-repo',
            'jp524',
            'something'
          )
        end

        context 'creates an associated Build' do
          before do
            Sidekiq::Testing.inline! do
              RespondWebhookPushJob.perform_async(
                repo.builds.first.id,
                repo.uuid,
                'test-repo',
                'jp524',
                'something'
              )
            end
          end

          let(:build) { repo.builds.first }

          scenario 'with first Log' do
            expect(build.logs.first.content).to eq("GitHub webhook 'push' received. Updating repository...")
          end

          scenario 'with second log' do
            expect(build.logs.second.content).to eq('No change to repository name or owner.')
          end

          scenario 'with third log' do
            expect(build.logs.third.content).to eq('Repository successfully pulled.')
          end

          scenario 'with fourth log' do
            expect(build.logs.fourth.content).to eq('index.md file exists for this repository.')
          end

          scenario "with status 'Complete'" do
            expect(build.status).to eq('Complete')
          end
        end

        after(:all) do
          directory = Rails.root.join('repos', 'jp524', 'test-repo')
          FileUtils.remove_dir(directory)
        end
      end

      context 'when an invalid request is received' do
        before do
          post "/webhooks/github/#{repo.uuid}",
               params: { 'repository': 'modified params render signature invalid' },
               headers: {
                 'X-GitHub-Event': 'push',
                 'X-Hub-Signature-256': signature
               }
        end

        scenario 'returns status 400' do
          expect(response.status).to eq(400)
        end
      end
    end
  end
end
