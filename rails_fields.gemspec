$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require "rails_fields/version"
require "date"

Gem::Specification.new do |spec|
  spec.name          = "rails-fields"
  spec.version       = RailsFields::VERSION
  spec.date          = Date.today.to_s
  spec.authors       = ["Gaston Morixe"]
  spec.email         = ["gaston@gastonmorixe.com"]
  spec.summary       = "Enforce field types and attributes for ActiveRecord models in Ruby on Rails applications."
  spec.description   = "The rails-fields gem provides robust field type enforcement for ActiveRecord models in Ruby on Rails applications. It includes utility methods for type validation, logging, and field mappings between GraphQL and ActiveRecord types. Custom error classes provide clear diagnostics for field-related issues, making it easier to maintain consistent data models."
  spec.homepage      = "https://github.com/gastonmorixe/rails-fields"
  spec.license       = "MIT"
  spec.files         = Dir["lib/**/*", "README.md"]
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.7"
end
