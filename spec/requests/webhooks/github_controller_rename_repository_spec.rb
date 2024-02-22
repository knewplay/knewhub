require 'rails_helper'

describe Webhooks::GithubController do
  describe "POST #create, 'X-GitHub-Event: repository' event & params[:action] = 'renamed'" do
    context 'when repository with given params exists' do
      before(:all) do
        # Create repository and its directory in `repos` folder
        @repo = create(:repository)
        @directory = @repo.storage_path
        FileUtils.mkdir_p(@directory)
        FileUtils.touch(@directory.join('index.md'))

        params = {
          action: 'renamed',
          changes: {
            repository: {
              name: {
                from: 'repo_name'
              }
            }
          },
          repository: {
            id: 123_456_789,
            name: 'new_repo_name'
          },
          installation: {
            id: 12_345_678
          },
          sender: {
            id: 44_555_666,
            login: 'repo_owner'
          }
        }

        secret = Rails.application.credentials.webhook_secret
        signature = "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, params.to_json)}"

        Sidekiq::Testing.inline! do
          post '/webhooks/github', as: :json, params:, headers: {
            'X-GitHub-Event': 'repository',
            'X-Hub-Signature-256': signature
          }
        end
      end

      after(:all) do
        parent_directory = Rails.root.join('repos', @repo.author_username)
        FileUtils.remove_dir(parent_directory)
      end

      it 'returns status :ok' do
        expect(response).to have_http_status(:ok)
      end

      it "modifies the repository's information" do
        @repo.reload
        expect(@repo.name).to eq('new_repo_name')
        expect(@repo.full_name).to eq('repo_owner/new_repo_name')
      end

      it 'changes the directory where the repository is stored' do
        expect(File).not_to exist(@directory)
        @repo.reload
        new_directory = @repo.storage_path
        expect(File).to exist(new_directory)
      end
    end

    context 'when repository with given params does not exist' do
      before(:all) do
        @params = {
          action: 'renamed',
          changes: {
            repository: {
              name: {
                from: 'repo_name'
              }
            }
          },
          repository: {
            id: 123_456_789,
            name: 'new_repo_name'
          },
          installation: {
            id: 12_345_678
          },
          sender: {
            id: 44_555_666,
            login: 'repo_owner'
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

      it 'writes an warn log' do
        allow(Rails.logger).to receive(:warn)
        post '/webhooks/github', as: :json, params: @params, headers: {
          'X-GitHub-Event': 'repository',
          'X-Hub-Signature-256': @signature
        }
        expect(Rails.logger).to have_received(:warn).with(
          'Could not find Repository with uid: 123456789 and ' \
          "name: repo_name for Github Installation with installation_id: 12345678.\n"
        )
      end
    end
  end
end
