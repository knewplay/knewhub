require 'rails_helper'

describe Auth::GithubController do
  describe 'GET #create' do
    context 'when the user is not yet an author' do
      let!(:user) { create(:user, author: nil) }

      before do
        sign_in user
      end

      context 'when a valid request is received' do
        before do
          VCR.use_cassette('receive_callback_github_auth') do
            get '/github/callback?code=a92fb7bc9ef2ac53f26e&installation_id=85654561&setup_action=install'
          end
        end

        it 'creates an author associated with the user' do
          expect(Author.last.user).to eq(user)
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

        it 'redirects to the root path' do
          expect(response).to redirect_to(root_path)
        end
      end
    end

    context 'when the user is already an author' do
      let!(:author) { create(:author, :real) }

      before do
        sign_in author.user
      end

      context 'when the code param results in the same author' do
        it 'redirects to the settings_author_repositories_path' do
          VCR.use_cassette('receive_callback_github_auth') do
            get '/github/callback?code=a92fb7bc9ef2ac53f26e&installation_id=12345678&setup_action=install'
          end
          expect(response).to redirect_to(settings_author_repositories_path)
        end
      end

      context 'when the code param results in a different author' do
        it 'redirects to the root path' do
          VCR.use_cassette('receive_callback_github_auth_different_author') do
            get '/github/callback?code=abcde12345&installation_id=12345678&setup_action=install'
          end

          expect(response).to redirect_to(root_path)
        end
      end
    end

    context 'when no user is logged in' do
      it 'redirects to the root path' do
        get '/github/callback?code=a92fb7bc9ef2ac53f26e&installation_id=12345678&setup_action=install'

        expect(response).to redirect_to(root_path)
      end
    end
  end
end
