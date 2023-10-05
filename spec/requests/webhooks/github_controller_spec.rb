require 'rails_helper'

describe Webhooks::GithubController do
  describe 'POST #create' do
    context "with a 'X-GitHub-Event: push' event" do
      before(:all) do
        # Creates and clones a repository
        @repo = create(:repository, :real, last_pull_at: DateTime.current)
        clone_build = create(:build, repository: @repo, aasm_state: :cloning_repo)
        Sidekiq::Testing.inline! do
          VCR.use_cassette('clone_github_repo') do
            CloneGithubRepoJob.perform_async(clone_build.id)
          end
        end

        # Parameters for Webhook event
        secret = Rails.application.credentials.webhook_secret
        data = 'repository[name]=test-repo&repository[owner][name]=jp524&'\
               'repository[owner][id]=85654561&repository[description]=something'
        @signature = "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, data)}"
      end

      context 'when a valid request is received' do
        before(:all) do
          post "/webhooks/github/#{@repo.uuid}",
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
                 'X-Hub-Signature-256': @signature
               }
        end

        scenario 'returns status 200' do
          expect(response.status).to eq(200)
        end

        context 'creates an associated Build' do
          before(:all) do
            @build = @repo.builds.last
            Sidekiq::Testing.inline! do
              RespondWebhookPushJob.perform_async(
                @build.id,
                @repo.uuid,
                'test-repo',
                'jp524',
                'something'
              )
            end
          end

          scenario 'with first Log' do
            expect(@build.logs.first.content).to eq("GitHub webhook 'push' received. Updating repository...")
          end

          scenario 'with second log' do
            expect(@build.logs.second.content).to eq('No change to repository name or owner.')
          end

          scenario 'with third log' do
            expect(@build.logs.third.content).to eq('Repository description successfully updated from GitHub.')
          end

          scenario 'with fourth log' do
            expect(@build.logs.fourth.content).to eq('Repository successfully pulled.')
          end

          scenario 'with fifth log' do
            expect(@build.logs.fifth.content).to eq('Questions successfully parsed.')
          end

          scenario 'with sixth log' do
            expect(@build.logs[5].content).to eq('index.md file exists for this repository.')
          end

          scenario "with status 'Complete'" do
            @build.reload
            expect(@build.status).to eq('Complete')
          end
        end

        after(:all) do
          directory = Rails.root.join('repos', @repo.author.github_username, @repo.name)
          FileUtils.remove_dir(directory)
        end
      end

      context 'when an invalid request is received' do
        before do
          post "/webhooks/github/#{@repo.uuid}",
               params: { 'repository': 'modified params render signature invalid' },
               headers: {
                 'X-GitHub-Event': 'push',
                 'X-Hub-Signature-256': @signature
               }
        end

        scenario 'returns status 400' do
          expect(response.status).to eq(400)
        end
      end
    end
  end
end
