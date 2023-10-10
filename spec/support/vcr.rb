VCR.configure do |config|
  config.cassette_library_dir = 'spec/cassettes'
  config.hook_into :webmock
  config.ignore_localhost = true
  config.filter_sensitive_data('<TOKEN>') { Rails.application.credentials.pat }
  config.filter_sensitive_data('<SECRET>') { Rails.application.credentials.webhook_secret }
  config.filter_sensitive_data('<HOST_URL>') { Rails.application.credentials.host_url }
end
