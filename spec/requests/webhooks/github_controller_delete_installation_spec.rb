require 'rails_helper'

describe Webhooks::GithubController do
  describe "POST #create, 'X-GitHub-Event: installation' event & params[:action] = 'deleted'" do
    context 'when a github installation with the given installation_id exists' do
      before(:all) do
        github_installation = create(:github_installation)
        create(:repository, github_installation:)
        @author = github_installation.author
        @repo_count = Repository.count
        @params = {
          action: 'deleted',
          installation: {
            account: {
              id: 44_555_666,
              login: 'repo_owner'
            },
            id: 12_345_678
          }
        }

        secret = Rails.application.credentials.webhook_secret
        @signature = "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, @params.to_json)}"
      end

      it 'returns status :ok' do
        post '/webhooks/github', as: :json, params: @params, headers: {
          'X-GitHub-Event': 'installation',
          'X-Hub-Signature-256': @signature
        }
        expect(response).to have_http_status(:ok)
      end

      it 'deletes the github installation' do
        post '/webhooks/github', as: :json, params: @params, headers: {
          'X-GitHub-Event': 'installation',
          'X-Hub-Signature-256': @signature
        }
        expect(@author.github_installations).to eq([])
      end

      it 'does not delete repositories association with the github installation' do
        post '/webhooks/github', as: :json, params: @params, headers: {
          'X-GitHub-Event': 'installation',
          'X-Hub-Signature-256': @signature
        }
        expect(Repository.count).to eq(@repo_count)
      end

      it 'calls the AuthorMailer' do
        expect do
          post '/webhooks/github', as: :json, params: @params, headers: {
            'X-GitHub-Event': 'installation',
            'X-Hub-Signature-256': @signature
          }
        end.to have_enqueued_job(ActionMailer::MailDeliveryJob).with(
          'AuthorMailer',
          'github_installation_deleted',
          'deliver_now',
          Hash
        )
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
