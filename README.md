<p align="center">
  <a href="https://rails-fields.dev" target="_blank"><img src="./assets/logo.svg" width="300" /></a>
</p>

[![Gem Version](https://badge.fury.io/rb/rails-fields.svg?v=320)](https://badge.fury.io/rb/rails-fields)

# Rails Fields

Enforce field types and attributes for ActiveRecord models in Ruby on Rails applications.

- 🚀 Auto-magic ActiveRecord **Migrations** generation
- 🦄 Automatic [GraphQL types](https://graphql-ruby.org/type_definitions/objects.html) generation
- 📝 Explicit **declarative** model attributes annotation
- 💪🏻 Enforcement of fields declaration with real db columns
- 📜 Automatic YARD model documentation

## Description
The `rails-fields` gem provides robust field type enforcement for ActiveRecord models in Ruby on Rails applications. It includes utility methods for type validation, logging, and field mappings between GraphQL and ActiveRecord types. Custom error classes provide clear diagnostics for field-related issues, making it easier to maintain consistent data models.

## Usage

In your ActiveRecord models:

```ruby
class User < ApplicationRecord
  field :id, :integer
  field :created_at, :datetime
  field :updated_at, :datetime

  field :first_name, :string
  field :country, :string
  field :welcome, :string

  has_many :todos
  
  def welcome
    "Welcome #{first_name}!"
  end
end
```

Autogenerate GraphQL types using `#gql_type` class method:

```ruby
module Types
  class QueryType < Types::BaseObject
    
    field :users, [User.gql_type], null: true
    
    def users
      User.all
    end
    
  end
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rails-fields'
```

If you want to have graphql types generated for your models, add this line to your application's Gemfile:

```ruby
gem 'graphql'
```

*Don't forget to install it `$ ./bin/rails generate graphql:install`*

And then execute:

```bash
$ bundle install
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Author

Gaston Morixe 2023 - gaston@gastonmorixe.com
