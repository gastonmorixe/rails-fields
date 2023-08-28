module RailsFields
  class EnforceFieldsMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      ApplicationRecord.descendants.each do |model|
        model.enforce_declared_fields # if model.respond_to?(:enforce_declared_fields)
      end
      @app.call(env)
    end
  end
end
