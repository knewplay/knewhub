module Sidekiq
  class Logger < ::Logger
    module Formatters
      class CustomFormatter < Base
        def call(severity, time, program_name, message)
          "#{severity}: #{message} | pid=#{::Process.pid} tid=#{tid}#{format_context} \n"
        end
      end
    end
  end
end

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL_SIDEKIQ', 'redis://localhost:6379/1') }
  config.logger = Logger.new(STDOUT)
  config.logger.formatter = Sidekiq::Logger::Formatters::CustomFormatter.new
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL_SIDEKIQ', 'redis://localhost:6379/1') }
end
