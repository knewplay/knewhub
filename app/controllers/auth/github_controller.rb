module Auth
  class GithubController < ApplicationController
    before_action :authenticate_user!, :verify_params

    def create
      user_access_token = user_access_token(params[:code])
      user_info = user_info(user_access_token)
      installation_id = params[:installation_id]
      github_uid = user_info['id']
      github_username = user_info['login']

      author = Author.find_by(github_uid:)
      update_or_create_author(author, installation_id, github_uid, github_username)
      redirect_to settings_author_repositories_path
    end

    private

    def update_or_create_author(author, installation_id, github_uid, github_username)
      if author
        author.update(installation_id:, github_username:)
      else
        Author.create!(user_id: current_user.id, installation_id:, github_uid:, github_username:)
      end
    rescue ActiveRecord::RecordInvalid => e
      logger.error "Could not create Author for user ##{current_user.id}: #{e}"
    end

    def user_access_token(code)
      params = {
        client_id: Rails.application.credentials.dig(:github, :client_id),
        client_secret: Rails.application.credentials.dig(:github, :client_secret),
        code:
      }

      conn = Faraday.new(url: 'https://github.com')
      response = conn.post('/login/oauth/access_token', params, { Accept: 'application/json' })

      token_data = JSON.parse(response.body)
      token_data['access_token']
    end

    def user_info(access_token)
      client = Octokit::Client.new(access_token:)
      client.user
    rescue Octokit::Unauthorized, Octokit::Forbidden => e
      logger.error "Could not get GitHub user info to create Author: #{e}"
    end

    def verify_params
      head :bad_request and return if params[:code].nil? || params[:installation_id].nil? || params[:setup_action].nil?
    end
  end
end
