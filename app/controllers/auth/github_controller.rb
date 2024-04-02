module Auth
  class GithubController < ApplicationController
    before_action :verify_params, :verify_user, :verify_author

    # GET /github/callback
    def create
      github_uid, github_username = user_info

      Author.create!(user_id: current_user.id, github_uid:, github_username:)
      redirect_to settings_author_repositories_path, notice: 'Author account successfully added.'
    rescue ActiveRecord::RecordInvalid => e
      logger.error "Could not create Author for user ##{current_user.id}: #{e}"
    end

    private

    def access_token
      client_id = ENV.fetch('GITHUB_CLIENT_ID', Rails.application.credentials.dig(:github, :client_id))
      client_secret = ENV.fetch('GITHUB_CLIENT_SECRET', Rails.application.credentials.dig(:github, :client_secret))
      request_params = { client_id:, client_secret:, code: params[:code] }

      conn = Faraday.new(url: 'https://github.com')
      response = conn.post('/login/oauth/access_token', request_params, { Accept: 'application/json' })

      token_data = JSON.parse(response.body)
      token_data['access_token']
    end

    def user_info
      client = Octokit::Client.new(access_token:)
      user = client.user
      [user['id'].to_s, user['login']]
    rescue Octokit::Unauthorized, Octokit::Forbidden => e
      logger.error "Could not get GitHub user info to create Author: #{e}"
    end

    def verify_user
      return if user_signed_in?

      notice = <<~MSG
        If you approved a GitHub App installation for another user, thank you. Otherwise please log in to continue.
      MSG
      redirect_to root_path, notice:
    end

    def verify_author
      return if current_user.author.nil?

      github_uid, _github_username = user_info
      if current_user.author.github_uid == github_uid
        redirect_to settings_author_repositories_path, notice: 'This installation will be added to your author account.'
      else
        alert = <<~MSG
          You are already an author on KNEWHUB with the GitHub username #{current_user.author.github_username}. Only one GitHub account can be linked per author account.
        MSG
        redirect_to root_path, alert:
      end
    end

    def verify_params
      redirect_to root_path, alert: 'Invalid request.' if params[:code].nil?
    end
  end
end
