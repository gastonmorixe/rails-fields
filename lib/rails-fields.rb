require "rails_fields/railtie"
require "rails_fields/errors/rails_fields_error"
require "rails_fields/errors/rails_fields_mismatch_error"
require "rails_fields/errors/rails_fields_unknown_type_error"
require "rails_fields/utils/logging"
require "rails_fields/utils/mappings"
require "rails_fields/utils/helpers"
require "rails_fields/class_methods"
require "rails_fields/instance_methods"
require "rails_fields/enforce_fields_middleware"

puts "RailsFields file root"

# Provides enforcement of declared field for ActiveRecord models.
module RailsFields
  puts "RailsFields module"
  @processed_classes = {}

  def self.processed_classes
    @processed_classes
  end

  # @param base [ActiveRecord::Base] the model to include the module in
  # def self.included(base)
  #   # base.extend(ClassMethods)
  #   # todo: raise if class methods not found
  #   # base.after_initialize do
  #   #   self.class.enforce_declared_fields
  #   # end
  # end
end
