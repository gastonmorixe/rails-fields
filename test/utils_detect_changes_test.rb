require "test_helper"

module RailsFields
  class UtilsDetectChangesTest < Minitest::Test
    class User < ::ApplicationRecord
      extend RailsFields::ClassMethods
      self.table_name = :users
    end

    def setup
      ActiveRecord::Base.connection.create_table :users, force: true do |t|
        t.string :name
      end
      User.reset_column_information
      User.declared_fields = []
    end

    def teardown
      ActiveRecord::Base.connection.drop_table :users, if_exists: true
    end

    def test_detects_added_field
      User.field :age, :integer

      changes = RailsFields::Utils.detect_changes(User)

      refute_nil changes, "Expected changes to be detected"
      added_names = changes[:added].map { |h| h[:name] }
      assert_includes added_names, :age
    end
  end
end
