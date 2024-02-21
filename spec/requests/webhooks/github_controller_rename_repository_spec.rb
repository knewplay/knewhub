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
        signature = "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, params.to_json)}"

        post '/webhooks/github', as: :json, params:, headers: {
          'X-GitHub-Event': 'repository',
          'X-Hub-Signature-256': signature
        }
      end

      after(:all) do
        parent_directory = Rails.root.join('repos', @repo.owner)
        FileUtils.remove_dir(parent_directory)
      end

      it 'returns status :ok' do
        expect(response).to have_http_status(:ok)
      end

      it "modifies the repository's information" do
        @repo.reload
        expect(@repo.name).to eq('new-name')
        expect(@repo.full_name).to eq('user/new-name')
      end

      it 'changes the directory where the repository is stored' do
        expect(File).not_to exist(@directory)
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

      it 'returns status :ok' do
        post '/webhooks/github', as: :json, params: @params, headers: {
          'X-GitHub-Event': 'repository',
          'X-Hub-Signature-256': @signature
        }
        expect(response).to have_http_status(:ok)
      end

      it 'writes an error log' do
        allow(Rails.logger).to receive(:error)
        post '/webhooks/github', as: :json, params: @params, headers: {
          'X-GitHub-Event': 'repository',
          'X-Hub-Signature-256': @signature
        }
        expect(Rails.logger).to have_received(:error).with(
          'Could not find Repository with uid: 123456789 and ' \
          "name: repo_name for Github Installation with installation_id: 12345678.\n"
        )
      end
    end
  end
end
