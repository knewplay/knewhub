require 'rails_helper'

describe Webhooks::GithubController do
  describe 'POST #create' do
    scenario 'X-GitHub-Event: ping' do
      secret = Rails.application.credentials.webhook_secret
      data = 'zen=Responsive+is+better+than+fast.'
      signature = "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, data)}"

      post "/webhooks/github/#{SecureRandom.uuid}",
          params: { 'zen': 'Responsive is better than fast.' },
          headers: {
            'X-GitHub-Event': 'ping',
            'X-Hub-Signature-256': signature
          }

      expect(response.status).to eq(200)
    end

    scenario 'X-GitHub-Event: push' do
      secret = Rails.application.credentials.webhook_secret
      data = 'repository[name]=repo_name&repository[owner][name]=user&'\
            'repository[owner][id]=12345&repository[description]=something'
      signature = "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, data)}"

      repo = create(:repository)

      post "/webhooks/github/#{repo.uuid}",
          params: {
            'repository': {
              'name': 'repo_name',
              'owner': {
                'name': 'user',
                'id': '12345'
              },
              'description': 'something'
            }
          },
          headers: {
            'X-GitHub-Event': 'push',
            'X-Hub-Signature-256': signature
          }

      expect(response.status).to eq(200)
    end
  end
end

