require 'rails_helper'

describe Webhooks::GithubController do
  describe "POST #create, 'X-GitHub-Event: repository' event & params[:action] = 'deleted'" do
    context 'when repository with given params exists' do
      before(:all) do
        # Create repository and its directory in `repos` folder
        @repo = create(:repository)
        @directory = @repo.storage_path
        FileUtils.mkdir_p(@directory)
        FileUtils.touch(@directory.join('index.md'))

        @repo_count = Repository.count
        @params = {
          action: 'deleted',
          changes: {
            repository: {
              name: {
                from: 'repo_name'
              }
            }
          },
          repository: {
            id: 123_456_789,
            name: 'new-name'
          },
          installation: {
            id: 12_345_678
          },
          sender: {
            id: 12_345_678,
            login: 'user'
          }
        }

        secret = Rails.application.credentials.webhook_secret
        @signature = "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, @params.to_json)}"
      end

      after(:all) do
        parent_directory = Rails.root.join('repos', @repo.owner)
        FileUtils.remove_dir(parent_directory)
      end

      it 'returns status :ok' do
        post '/webhooks/github', as: :json, params: @params, headers: {
          'X-GitHub-Event': 'repository',
          'X-Hub-Signature-256': @signature
        }
        expect(response).to have_http_status(:ok)
      end

      it 'does not delete the repository' do
        post '/webhooks/github', as: :json, params: @params, headers: {
          'X-GitHub-Event': 'repository',
          'X-Hub-Signature-256': @signature
        }
        expect(Repository.count).to eq(@repo_count)
      end

      it 'calls the AuthorMailer' do
        expect do
          post '/webhooks/github', as: :json, params: @params, headers: {
            'X-GitHub-Event': 'repository',
            'X-Hub-Signature-256': @signature
          }
        end.to have_enqueued_job(ActionMailer::MailDeliveryJob).with(
          'AuthorMailer',
          'repository_deleted',
          'deliver_now',
          Hash
        )
      end
    end

    context 'when repository with given params does not exist' do
      let!(:initial_count) { Repository.count }

      before(:all) do
        @params = {
          action: 'deleted',
          changes: {
            repository: {
              name: {
                from: 'some-repo'
              }
            }
          },
          repository: {
            id: 88_777_666,
            name: 'some-repo-new-name'
          },
          installation: {
            id: 00_000_0000
          },
          sender: {
            id: 11_444_777,
            login: 'another-user'
          }
        }

        secret = Rails.application.credentials.webhook_secret
        @signature = "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, @params.to_json)}"
      end

      it 'returns status :ok' do
        post '/webhooks/github', as: :json, params: @params, headers: {
          'X-GitHub-Event': 'repository',
          'X-Hub-Signature-256': @signature
        }
        expect(response).to have_http_status(:ok)
      end

      it 'does not remove a repository' do
        post '/webhooks/github', as: :json, params: @params, headers: {
          'X-GitHub-Event': 'repository',
          'X-Hub-Signature-256': @signature
        }
        final_count = Repository.count
        expect(initial_count).to eq(final_count)
      end

      it 'writes an error log' do
        allow(Rails.logger).to receive(:error)
        post '/webhooks/github', as: :json, params: @params, headers: {
          'X-GitHub-Event': 'repository',
          'X-Hub-Signature-256': @signature
        }
        expect(Rails.logger).to have_received(:error).with(
          'Could not find Repository with uid: 88777666 and ' \
          "name: some-repo for Github Installation with installation_id: 0.\n"
        )
      end
    end
  end
end
