module RailsFields
  module Utils
    class << self
      def allowed_types
        # TODO: this may depend on the current database adapter or mapper
        ActiveRecord::Base.connection.native_database_types.keys
      end

      def valid_type?(type)
        # TODO: this may depend on the current database adapter or mapper
        allowed_types.include?(type)
      end

      def active_record_models
        Rails.application.eager_load! # Ensure all models are loaded

        ActiveRecord::Base.descendants.reject do |model|
          !(model.is_a?(Class) && model < ApplicationRecord) ||
            model.abstract_class? ||
            model.name.nil? ||
            model.name == "ActiveRecord::SchemaMigration"
        end
      end

      # Detect changes between the ActiveRecord model declared fields and the database structure.
      # @example
      #   model_changes = FieldEnforcement::Utils.detect_changes(User)
      #   # => {
      #     added: [],
      #     removed: [],
      #     renamed: [],
      #     type_changed: [],
      #     potential_renames: []
      #   }
      # @param model [ActiveRecord::Base] the model to check
      # @return [Hash, Nil] the changes detected
      def detect_changes(model)
        previous_fields = model.attribute_types.to_h { |k, v| [k.to_sym, v.type] }
        declared_fields = model.declared_fields.to_h do |f|
          [f.name.to_sym, {
            name: f.type.to_sym,
            options: f.options
          }]
        end

        LOGGER.debug "Log: previous_fields: #{previous_fields}"
        LOGGER.debug "Log: declared_fields #{declared_fields}}"

        model_changes = {
          added: [],
          removed: [],
          renamed: [],
          type_changed: [],
          potential_renames: [],
          associations_added: [],
          associations_removed: []
        }

        # Detect added and type-changed fields
        declared_fields.each do |name, type|
          type_name = type[:name]
          if previous_fields[name]
            if previous_fields[name] != type_name
              model_changes[:type_changed] << { name:, from: previous_fields[name], to: type }
            end
          else
            model_changes[:added] << { name:, type: }
          end
        end

        LOGGER.debug "Log: model_changes[:added] before filter #{model_changes[:added]}"
        # Remove added fields that have a defined method in the the model
        model_changes[:added] = model_changes[:added].filter { |f| !model.instance_methods.include?(f[:name]) }
        LOGGER.debug "Log: model_changes[:added] after filter #{model_changes[:added]}"

        # Detect removed fields
        removed_fields = previous_fields.keys - declared_fields.keys
        model_changes[:removed] = removed_fields.map { |name| { name:, type: previous_fields[name] } }

        LOGGER.debug "Log: model_changes[:removed] 1 #{model_changes[:removed]}"

        # Remove foreign keys from removed fields
        associations = model.reflections.values.map(&:foreign_key).map(&:to_sym)
        model_changes[:removed].reject! { |f| associations.include?(f[:name]) }

        LOGGER.debug "Log: model_changes[:removed] 2 #{model_changes[:removed]} | associations #{associations}"

        # Detect potential renames
        potential_renames = []
        model_changes[:removed].each do |removed_field|
          # puts "Log: removed_field: #{removed_field}"
          added_field = model_changes[:added].find { |f| f[:type] == removed_field[:type] }
          if added_field
            potential_renames << { from: removed_field[:name],
                                   to: added_field[:name] }
          end
        end

        LOGGER.debug "Log: potential_renames: #{potential_renames}"

        model_changes[:potential_renames] = potential_renames

        # Filter out incorrect renames (one-to-one mapping)
        potential_renames.each do |rename|
          next unless model_changes[:added].count { |f| f[:type] == rename[:to].to_sym } == 1 &&
            model_changes[:removed].count { |f| f[:type] == rename[:from].to_sym } == 1

          model_changes[:renamed] << rename
          model_changes[:added].reject! { |f| f[:name] == rename[:to].to_sym }
          model_changes[:removed].reject! { |f| f[:name] == rename[:from].to_sym }
        end

        # Handle associations changes
        declared_associations = model.reflections.values.select do |reflection|
          [:belongs_to].include?(reflection.macro)
        end

        declared_foreign_keys = declared_associations.map(&:foreign_key).map(&:to_sym)
        existing_foreign_keys = ActiveRecord::Base.connection.foreign_keys(model.table_name).map(&:options).map { |opt| opt[:column].to_sym }

        associations_added = declared_associations.select do |reflection|
          !existing_foreign_keys.include?(reflection.foreign_key.to_sym)
        end

        associations_removed = existing_foreign_keys.select do |foreign_key|
          !declared_foreign_keys.include?(foreign_key)
        end.map { |foreign_key| model.reflections.values.find { |reflection| reflection.foreign_key == foreign_key.to_s } }

        model_changes[:associations_added] = associations_added
        model_changes[:associations_removed] = associations_removed

        return model_changes unless model_changes.values.all?(&:empty?)

        nil
      end

      def generate_migration(model, model_changes, index: 0, write: false)
        return if model_changes.blank?

        model_name = model.name
        timestamp = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i + index
        migration_class_name = "#{model_name}Migration#{timestamp}"

        migration_code = []
        migration_code << "class #{migration_class_name} < ActiveRecord::Migration[#{ActiveRecord::Migration.current_version}]"

        migration_code << "  def change"

        model_changes.dig(:added)&.each do |change|
          field_type = change[:type]
          field_type_for_db = field_type[:name]
          # TODO: custom mapper
          migration_code << "    add_column :#{model_name.tableize}, :#{change[:name]}, :#{field_type_for_db}"
        end

        # Handle added associations
        model_changes.dig(:associations_added)&.each do |assoc|
          migration_code << "    add_reference :#{model_name.tableize}, :#{assoc.name}, foreign_key: true"
        end

        # Handle removed associations
        model_changes.dig(:associations_removed)&.each do |assoc|
          migration_code << "    remove_reference :#{model_name.tableize}, :#{assoc.name}, foreign_key: true"
        end

        # Handle removed fields
        model_changes.dig(:removed)&.each do |change|
          migration_code << "    remove_column :#{model_name.tableize}, :#{change[:name]}"
        end

        # Handle renamed fields
        model_changes.dig(:renamed)&.each do |change|
          change_to = change[:to]
          migration_code << "    rename_column :#{model_name.tableize}, :#{change[:from]}, :#{change_to}"
        end

        # Handle fields' type changes
        model_changes.dig(:type_changed)&.each do |change|
          change_to = change[:to][:name]
          migration_code << "    change_column :#{model_name.tableize}, :#{change[:name]}, :#{change_to}"
        end

        migration_code << "  end"
        migration_code << "end"
        migration_code << ""

        write_migration(migration_code, migration_class_name, timestamp) if write

        migration_code.join("\n")
      end

      def write_migration(migration_code, migration_class_name, timestamp)
        migration_filename = "#{timestamp}_#{migration_class_name.underscore}.rb"
        migration_path = Rails.root.join("db", "migrate", migration_filename)
        File.write(migration_path, migration_code.join("\n"))
        LOGGER.info "Migration saved at #{migration_path}"
        { migration_filename:, migration_path: }
      end
    end
  end
end
