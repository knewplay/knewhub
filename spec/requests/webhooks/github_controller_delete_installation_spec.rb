require 'rails_helper'

describe Webhooks::GithubController do
  describe "POST #create, 'X-GitHub-Event: installation' event & params[:action] = 'deleted'" do
    context 'when a github installation with the given installation_id exists' do
      before(:all) do
        github_installation = create(:github_installation)
        create(:repository, github_installation:)
        @author = github_installation.author
        @repo_count = Repository.count
        params = {
          action: 'deleted',
          installation: {
            account: {
              id: 12_345_678,
              login: 'user'
            },
            id: 12_345_678
          }
        }

        secret = Rails.application.credentials.webhook_secret
        signature = "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, params.to_json)}"

        post '/webhooks/github', as: :json, params:, headers: {
          'X-GitHub-Event': 'installation',
          'X-Hub-Signature-256': signature
        }
      end

      context 'without a requester' do
        it 'returns status :ok' do
          expect(response).to have_http_status(:ok)
        end

        it 'deletes the github installation' do
          expect(@author.github_installations).to eq([])
        end

        it 'does not delete repositories association with the github installation' do
          expect(Repository.count).to eq(@repo_count)
        end
      end
    end

    context 'when a github installation with the given installation_id does not exist' do
      let!(:initial_count) { GithubInstallation.count }

      before(:all) do
        params = {
          action: 'deleted',
          installation: {
            account: {
              id: 11_444_777,
              login: 'another-user'
            },
            id: 00_000_0000
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

      it 'does not remove a github installation' do
        final_count = GithubInstallation.count
        expect(initial_count).to eq(final_count)
      end
    end
  end
end
