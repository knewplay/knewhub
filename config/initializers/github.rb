Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, Rails.application.credentials.github_id, Rails.application.credentials.github_secret
end
