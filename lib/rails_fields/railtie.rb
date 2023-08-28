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
      app.middleware.insert_after ActiveRecord::Migration::CheckPending, RailsFields::EnforceFieldsMiddleware
    end
  end
end