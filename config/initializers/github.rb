Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github,
           ENV.fetch('GITHUB_APP_ID', Rails.application.credentials.github_id),
           ENV.fetch('GITHUB_APP_SECRET', Rails.application.credentials.github_secret)
end
