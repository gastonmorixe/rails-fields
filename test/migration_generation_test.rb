require "test_helper"

module RailsFields
  class MigrationGenerationTest < Minitest::Test
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

    def test_generates_add_column_for_added_field
      User.field :age, :integer

      changes = RailsFields::Utils.detect_changes(User)
      migration = RailsFields::Utils.generate_migration(User, changes)

      assert_includes migration, "add_column :users, :age, :integer"
    end
  end
end
