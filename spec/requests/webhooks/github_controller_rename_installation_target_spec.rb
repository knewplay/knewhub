require 'rails_helper'

describe Webhooks::GithubController do
  describe "POST #create, 'X-GitHub-Event: installation_target' event & params[:action] = 'renamed'" do
    context 'when github_installation with given params exists' do
      before(:all) do
        @github_installation = create(:github_installation)
        # Create repository and its directory in `repos` folder
        @repo = create(:repository, github_installation: @github_installation)
        @directory = @repo.storage_path
        FileUtils.mkdir_p(@directory)
        FileUtils.touch(@directory.join('index.md'))

        params = {
          action: 'renamed',
          changes: {
            login: {
              from: 'repo_owner'
            }
          },
          account: {
            login: 'new_repo_owner',
            id: 44_555_666
          },
          installation: {
            id: 12_345_678
          }
        }

        secret = Rails.application.credentials.webhook_secret
        signature = "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, params.to_json)}"

        Sidekiq::Testing.inline! do
          post '/webhooks/github', as: :json, params:, headers: {
            'X-GitHub-Event': 'installation_target',
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

      it "modifies the github installation's information" do
        @github_installation.reload
        expect(@github_installation.username).to eq('new_repo_owner')
      end

      it 'changes the directory where the repository is stored' do
        expect(File).not_to exist(@directory)
        @repo.reload
        new_directory = @repo.storage_path
        expect(File).to exist(new_directory)
      end
    end

    context 'when github installation with given params does not exist' do
      before(:all) do
        @params = {
          action: 'renamed',
          changes: {
            login: {
              from: 'repo_owner'
            }
          },
          account: {
            login: 'new_repo_owner',
            id: 44_555_666
          },
          installation: {
            id: 00_000_000
          }
        }

        secret = Rails.application.credentials.webhook_secret
        @signature = "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, @params.to_json)}"
      end

      it 'returns status :ok' do
        post '/webhooks/github', as: :json, params: @params, headers: {
          'X-GitHub-Event': 'installation_target',
          'X-Hub-Signature-256': @signature
        }
        expect(response).to have_http_status(:ok)
      end

      it 'writes an error log' do
        allow(Rails.logger).to receive(:error)
        post '/webhooks/github', as: :json, params: @params, headers: {
          'X-GitHub-Event': 'installation_target',
          'X-Hub-Signature-256': @signature
        }
        expect(Rails.logger).to have_received(:error).with(
          'Could not find Github Installation with installation_id: 0 and uid: 44555666.'
        )
      end
    end
  end
end
