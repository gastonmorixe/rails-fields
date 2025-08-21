require "active_support"
require "active_support/rails"
require "rails_fields/enforce_fields_middleware"

module RailsFields
  class Railtie < Rails::Railtie
    # config.eager_load_namespaces << RailsFields

    initializer "rails_fields.initialize" do
      ActiveSupport.on_load(:active_record) do
        extend RailsFields::ClassMethods
        include RailsFields
      end
    end

    initializer "rails_fields.middleware" do |app|
      # In Rails 8, ActiveRecord::Migration::CheckPending was removed.
      # Try to insert after it when present; otherwise, append the middleware.
      if defined?(Rails::VERSION) && Rails::VERSION::MAJOR >= 8
        # Rails 8 removed ActiveRecord::Migration::CheckPending from the stack
        app.middleware.use RailsFields::EnforceFieldsMiddleware
      else
        begin
          app.middleware.insert_after ActiveRecord::Migration::CheckPending, RailsFields::EnforceFieldsMiddleware
        rescue StandardError
          # Fallback for environments where insert_after target is unavailable
          app.middleware.use RailsFields::EnforceFieldsMiddleware
        end
      end
    end
  end
end
