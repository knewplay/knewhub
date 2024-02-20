require 'rails_helper'

describe Webhooks::GithubController do
  describe 'POST #create' do
    context "with a 'X-GitHub-Event: push' event" do
      before(:all) do
        # Creates and clones a repository
        @repo = create(:repository, :real, last_pull_at: DateTime.current)
        clone_build = create(:build, repository: @repo, aasm_state: :cloning_repo)
        # HTTP request required to clone repository using Octokit client
        VCR.turn_off!
        WebMock.allow_net_connect!
        Sidekiq::Testing.inline! do
          CloneGithubRepoJob.perform_async(clone_build.id)
        end
        VCR.turn_on!
        WebMock.disable_net_connect!
      end

      context 'when a valid request is received' do
        before(:all) do
          params = {
            repository: {
              description: 'something',
              id: 663_068_537,
              name: 'test-repo',
              owner: {
                id: 85_654_561,
                name: 'jp524'
              }
            }
          }

          secret = Rails.application.credentials.webhook_secret
          signature = "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, params.to_json)}"

          post '/webhooks/github', as: :json, params:, headers: {
            'X-GitHub-Event': 'push',
            'X-Hub-Signature-256': signature
          }
        end

        after(:all) do
          FileUtils.remove_dir(@repo.storage_path)
        end

        it 'returns status :ok' do
          expect(response).to have_http_status(:ok)
        end

        context 'when creating an associated Build' do
          before(:all) do
            @build = @repo.builds.last
            Sidekiq::Testing.inline! do
              RespondWebhookPushJob.perform_async(
                @build.id,
                @repo.uid,
                'test-repo',
                'jp524',
                'something'
              )
            end
          end

          it 'with first Log' do
            expect(@build.logs.first.content).to eq("GitHub webhook 'push' received. Updating repository...")
          end

          it 'with second log' do
            expect(@build.logs.second.content).to eq('No change to repository name or owner.')
          end

          it 'with third log' do
            expect(@build.logs.third.content).to eq('Repository description successfully updated from GitHub.')
          end

          it 'with fourth log' do
            expect(@build.logs.fourth.content).to eq('Repository successfully pulled.')
          end

          it 'with fifth log' do
            expect(@build.logs.fifth.content).to eq('Questions successfully parsed.')
          end

          it 'with sixth log' do
            expect(@build.logs[5].content).to eq('index.md file exists for this repository.')
          end

          it "with status 'Complete'" do
            @build.reload
            expect(@build.status).to eq('Complete')
          end
        end
      end

      context 'when an invalid request is received' do
        before do
          old_params = {
            repository: {
              description: 'something',
              id: 663_068_537,
              name: 'test-repo',
              owner: {
                id: 85_654_561,
                name: 'jp524'
              }
            }
          }

          new_params = { repository: 'modified params render signature invalid' }

          secret = Rails.application.credentials.webhook_secret
          signature = "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, old_params.to_json)}"

          post '/webhooks/github', as: :json, params: new_params, headers: {
            'X-GitHub-Event': 'push',
            'X-Hub-Signature-256': signature
          }
        end

        it 'returns status :bad_request' do
          expect(response).to have_http_status(:bad_request)
        end
      end
    end

    context "with a 'X-GitHub-Event: installation' event & params[:action] = 'created'" do
      context 'when author with given uid exists' do
        before(:all) do
          @author = create(:author)
        end

        context 'with a requester' do
          before(:all) do
            params = {
              action: 'created',
              installation: {
                account: {
                  id: 111_222_333,
                  login: 'some-org'
                },
                id: 44_555_666
              },
              requester: {
                id: 12_345_678,
                login: 'user'
              }
            }

            secret = Rails.application.credentials.webhook_secret
            signature = "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, params.to_json)}"

            post '/webhooks/github', as: :json, params:, headers: {
              'X-GitHub-Event': 'installation',
              'X-Hub-Signature-256': signature
            }
          end

          it 'returns status :ok' do
            expect(response).to have_http_status(:ok)
          end

          it 'creates a github installation' do
            gh_installation = @author.github_installations.last
            expect(gh_installation.installation_id).to eq('44555666')
            expect(gh_installation.uid).to eq('111222333')
            expect(gh_installation.username).to eq('some-org')
          end
        end

        context 'without a requester' do
          before(:all) do
            params = {
              action: 'created',
              installation: {
                account: {
                  id: 12_345_678,
                  login: 'user'
                },
                id: 77_888_999
              },
              requester: nil,
              sender: {
                id: 12_345_678,
                login: 'user'
              }
            }

            secret = Rails.application.credentials.webhook_secret
            signature = "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, params.to_json)}"

            post '/webhooks/github', as: :json, params:, headers: {
              'X-GitHub-Event': 'installation',
              'X-Hub-Signature-256': signature
            }
          end

          it 'returns status :ok' do
            expect(response).to have_http_status(:ok)
          end

          it 'creates a github installation' do
            gh_installation = @author.github_installations.last
            expect(gh_installation.installation_id).to eq('77888999')
            expect(gh_installation.uid).to eq('12345678')
            expect(gh_installation.username).to eq('user')
          end
        end
      end

      context 'when author with given uid does not exist' do
        let!(:initial_count) { GithubInstallation.count }

        before(:all) do
          params = {
            action: 'created',
            installation: {
              account: {
                id: 11_444_777,
                login: 'another-user'
              },
              id: 00_000_0000
            },
            requester: nil,
            sender: {
              id: 11_444_777,
              login: 'another-user'
            }
          }

          secret = Rails.application.credentials.webhook_secret
          signature = "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, params.to_json)}"

          post '/webhooks/github', as: :json, params:, headers: {
            'X-GitHub-Event': 'installation',
            'X-Hub-Signature-256': signature
          }
        end

        it 'returns status :ok' do
          expect(response).to have_http_status(:ok)
        end

        it 'does not create a github installation' do
          final_count = GithubInstallation.count
          expect(initial_count).to eq(final_count)
        end
      end
    end
  end
end
