require "test_helper"

module RailsFields
  class UtilsTest < Minitest::Test
    class User < ::ApplicationRecord
      extend RailsFields::ClassMethods
      self.table_name = :users
    end

    def setup
      ActiveRecord::Base.connection.create_table :users, force: true do |t|
        t.string :name
        t.string :email
      end
      User.reset_column_information
      User.declared_fields = []
    end

    def teardown
      ActiveRecord::Base.connection.drop_table :users, if_exists: true
    end

    def test_detect_changes_added_field
      User.field :age, :integer

      changes = RailsFields::Utils.detect_changes(User)

      refute_nil changes
      assert_equal [:age], changes[:added].map { |c| c[:name] }
    end

    def test_detect_changes_removed_field
      User.field :name, :string

      changes = RailsFields::Utils.detect_changes(User)

      refute_nil changes
      assert_equal [:email], changes[:removed].map { |c| c[:name] }
    end

    def test_detect_changes_renamed_field
      User.field :full_name, :string # Renamed from name
      User.field :email, :string

      changes = RailsFields::Utils.detect_changes(User)

      refute_nil changes
      assert_equal [{ from: :name, to: :full_name }], changes[:renamed]
    end

    def test_detect_changes_type_changed_field
      User.field :name, :text # Type changed from string to text
      User.field :email, :string

      changes = RailsFields::Utils.detect_changes(User)

      refute_nil changes
      assert_equal [{ name: :name, from: :string, to: { name: :text, options: nil } }], changes[:type_changed]
    end

    def test_detect_changes_no_changes
      User.field :name, :string
      User.field :email, :string

      changes = RailsFields::Utils.detect_changes(User)

      assert_nil changes
    end

    def test_generate_migration_for_added_field
      changes = { added: [{ name: :age, type: { name: :integer } }] }
      migration = RailsFields::Utils.generate_migration(User, changes)

      assert_includes migration, "add_column :users, :age, :integer"
    end

    def test_generate_migration_for_removed_field
      changes = { removed: [{ name: :email }] }
      migration = RailsFields::Utils.generate_migration(User, changes)

      assert_includes migration, "remove_column :users, :email"
    end

    def test_generate_migration_for_renamed_field
      changes = { renamed: [{ from: :name, to: :full_name }] }
      migration = RailsFields::Utils.generate_migration(User, changes)

      assert_includes migration, "rename_column :users, :name, :full_name"
    end

    def test_generate_migration_for_type_changed_field
      changes = { type_changed: [{ name: :name, to: { name: :text } }] }
      migration = RailsFields::Utils.generate_migration(User, changes)

      assert_includes migration, "change_column :users, :name, :text"
    end
  end
end
