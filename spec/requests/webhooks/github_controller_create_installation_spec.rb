require 'rails_helper'

describe Webhooks::GithubController do
  describe "POST #create, 'X-GitHub-Event: installation' event & params[:action] = 'created'" do
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
