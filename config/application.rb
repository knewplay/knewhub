require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Knewhub
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Change cache format for Rails 7.1
    config.active_support.cache_format_version = 7.1

    # Use ErrorsController to handle exceptions
    config.exceptions_app = routes

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Prevent creation of `div class="field_with_errors"` wrapper upon invalid form submission
    config.action_view.field_error_proc = ->(html_tag, _instance) { html_tag.html_safe }

    # Configure queue adapter to use with Action Mailer (relying on Active Job)
    # Other jobs are done with native Sidekiq
    config.active_job.queue_adapter = :sidekiq
  end
end
