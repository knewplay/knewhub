WebAuthn.configure do |config|
  config.origin = 'http://localhost:3000'
  config.rp_name = 'Knewhub'
  config.credential_options_timeout = 120_000
end
