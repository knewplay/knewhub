require 'rails_helper'

describe Auth::GithubController do
  let!(:user) { create(:user, author: nil) }
  let!(:installation_id) { '85654561' }

  before do
    sign_in user
  end

  describe 'GET #create' do
    context 'when a valid request is received' do
      before do
        VCR.use_cassette('receive_callback_github_auth') do
          get "/github/callback?code=a92fb7bc9ef2ac53f26e&installation_id=#{installation_id}&setup_action=install"
        end
      end

      it 'creates an author associated with the user' do
        expect(Author.last.user).to eq(user)
      end

      it 'has the information provided in the request' do
        user.reload
        expect(user.author.installation_id).to eq(installation_id)
      end

      it 'fetched the user info from GitHub' do
        user.reload
        expect(user.author.github_uid).to eq('85654561')
        expect(user.author.github_username).to eq('jp524')
      end
    end

    context 'when a request with invalid params is received' do
      before do
        get '/github/callback?installation_id=47084145&setup_action=install'
      end

      it 'returns status :bad_request' do
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
