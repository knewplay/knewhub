require 'rails_helper'

describe 'POST /webhooks/github' do
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
    data = 'repository[name]=repo_name&repository[owner][name]=owner_name&'\
           'repository[owner][id]=12345&repository[description]=something'
    signature = "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, data)}"

    author = Author.create(github_uid: '12345', github_username: 'owner_name')
    repo = Repository.create(name: 'repo_name', token: 'ghp_abde12345', author:)

    post "/webhooks/github/#{repo.uuid}",
         params: {
           'repository': {
             'name': 'repo_name',
             'owner': {
               'name': 'owner_name',
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
