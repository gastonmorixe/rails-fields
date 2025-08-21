module RailsFields
  module Utils
    # Define maps only if GraphQL is available
    if defined?(GraphQL)
      # TODO: mapper can be different or custom
      GQL_TO_RAILS_TYPE_MAP = {
        ::GraphQL::Types::String => :string,
        ::GraphQL::Types::Int => :integer,
        ::GraphQL::Types::Float => :float,
        ::GraphQL::Types::Boolean => :boolean,
        ::GraphQL::Types::ID => :integer, # or :string depending on how you handle IDs
        ::GraphQL::Types::ISO8601DateTime => :datetime,
        ::GraphQL::Types::ISO8601Date => :date,
        ::GraphQL::Types::JSON => :json,
        ::GraphQL::Types::BigInt => :bigint
      }.freeze

      RAILS_TO_GQL_TYPE_MAP = {
        # id: ::GraphQL::Types::String,
        string: ::GraphQL::Types::String,
        integer: ::GraphQL::Types::Int,
        float: ::GraphQL::Types::Float,
        boolean: ::GraphQL::Types::Boolean,
        datetime: ::GraphQL::Types::ISO8601DateTime,
        date: ::GraphQL::Types::ISO8601Date,
        json: ::GraphQL::Types::JSON,
        bigint: ::GraphQL::Types::BigInt,
        text: ::GraphQL::Types::String
      }.freeze
    end
  end
end
