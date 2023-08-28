$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require "rails_fields/version"
require "date"

Gem::Specification.new do |spec|
  spec.name = "rails-fields"
  spec.version = RailsFields::VERSION
  spec.date = Date.today.to_s
  spec.authors = ["Gaston Morixe"]
  spec.email = ["gaston@gastonmorixe.com"]
  spec.summary = "Enforce field types and attributes for ActiveRecord models in Ruby on Rails applications."
  spec.description = <<-STRING
    rails-fields gem provides robust field type enforcement for ActiveRecord models in Ruby on Rails applications.
    It includes utility methods for type validation, logging, and field mappings between GraphQL and ActiveRecord types
    Custom error classes provide clear diagnostics for field-related issues, making it easier to maintain consistent data models.
  STRING
  spec.homepage = "https://github.com/gastonmorixe/rails-fields"
  spec.license = "MIT"
  spec.files = Dir["lib/**/*", "README.md"]
  spec.require_paths = ["lib"]
  spec.metadata = {
    "homepage_uri" => "https://rails-fields.dev",
    "source_code_uri" => "https://github.com/gastonmorixe/rails-fields",
    "bug_tracker_uri" => "https://github.com/gastonmorixe/rails-fields/issues"
  }

  # Ruby
  spec.required_ruby_version = ">= 2.7"

  # Dependencies
  spec.add_dependency "rails", ">= 5.0"
  # spec.add_dependency "graphql", ">= 2.0.0"

  # Development Dependencies
  spec.add_development_dependency "graphql"
  spec.add_development_dependency "yard"
end
