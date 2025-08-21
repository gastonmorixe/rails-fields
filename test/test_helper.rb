# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "dummy/config/environment"
require "minitest/autorun"

# Disable available locale checks to avoid warnings
I18n.enforce_available_locales = false
