Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL_SIDEKIQ', 'redis://localhost:6379/1') }
  config.logger = Logger.new(STDOUT)
  config.logger.formatter = proc do |severity, _time, _progname, msg|
    "#{severity}: #{msg}\n"
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL_SIDEKIQ', 'redis://localhost:6379/1') }
end
