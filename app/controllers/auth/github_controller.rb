module Auth
  class GithubController < ApplicationController
    before_action :authenticate_user!

    def create
      create_user(params)
      redirect_to root_path
    end

    private

    def create_user(params)
      user_access_token = user_access_token(params[:code])
      user_info = user_info(user_access_token)

      Author.create!(
        user_id: current_user.id,
        installation_id: params[:installation_id],
        github_uid: user_info['id'],
        github_username: user_info['login']
      )
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
  end
end
