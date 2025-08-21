require_relative "boot"

require "active_record/railtie"

Bundler.require(*Rails.groups)
require "rails-fields"

module Dummy
  class Application < Rails::Application
    # Initialize configuration defaults for Rails 8.0.
    config.load_defaults 8.0

    # Ensure the app root is the dummy folder
    config.root = File.expand_path("..", __dir__)

    # For compatibility with applications that use this config
    config.action_controller.allow_forgery_protection = false
  end
end
