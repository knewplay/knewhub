class Github
  def access_token
    access_token = Octokit::Client.new(bearer_token: jwt).create_app_installation_access_token(installation_id)
    access_token[:token]
  end

  def installation_id
    Rails.application.credentials.dig(:github, :installation_id)
  end

  def jwt
    payload = {
      # issued at time, 60 seconds in the past to allow for clock drift
      iat: Time.now.to_i - 60,
      # JWT expiration time (10 minute maximum)
      exp: Time.now.to_i + (10 * 60),
      # GitHub App's identifier
      iss: Rails.application.credentials.dig(:github, :app_id)
    }
    JWT.encode(payload, private_key, 'RS256')
  end

  def private_key
    OpenSSL::PKey::RSA.new(pem)
  end

  def pem
    Rails.application.credentials.dig(:github, :private_key)
  end
end
