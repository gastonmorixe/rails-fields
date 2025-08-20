module RailsFields
  # Lightweight, typed container for field declarations
  # Include :options to maintain compatibility with code that reads it
  DeclaredField = Struct.new(:name, :type, :null, :index, :options, keyword_init: true)
  module ClassMethods
    # TODO: Check  all models at rails init app? like migrations?

    def declared_fields
      @declared_fields ||= []
    end

    def declared_fields=(value)
      @declared_fields = value
    end

    def write_migration(index: nil)
      changes = RailsFields::Utils.detect_changes(self)
      RailsFields::Utils.generate_migration(self, changes, index:, write: true)
    end

    # Declares a field with enforcement.
    #
    # @!method
    #   @param name [Symbol] the name of the field
    #   @param type [Symbol] the type of the field
    #   @param null [Boolean] whether the field can be null (default: true)
    #   @param index [Boolean] whether to index the field (default: false)
    #   @return [void]
    #
    # @!macro [attach] field
    #   @!attribute $1
    #   @return [$2] the $1 property
    def field(name, type, null: true, index: false)
      # Check if type is a valid GraphQL type
      # GraphQL::Types.const_get(type) if type.is_a?(Symbol) || type.is_a?(String)
      unless Utils.valid_type?(type)
        raise Errors::RailsFieldsUnknownTypeError.new("
          Declared field '#{name}' in class '#{self.name}' of unknown type '#{type}'. Allowed types are: #{Utils.allowed_types.join(', ')}.
        ")
      end

      declared_fields << DeclaredField.new(name: name.to_s, type:, null:, index:)
    end

    def gql_type
      return RailsFields.processed_classes[self] if RailsFields.processed_classes[self].present?

      fields = declared_fields
      owner_self = self

      type = Class.new(::Types::BaseObject) do
        # graphql_name "#{owner_self.name}Type"
        graphql_name "#{owner_self.name}"
        description "A type representing a #{owner_self.name}"

        fields.each do |f|
          next if f.type.nil? # TODO: ! remove references fields

          # Assuming a proper mapping from your custom types to GraphQL types
          # TODO: use a better method or block
          field_gql_type = f.name == :id ? GraphQL::Types::ID : Utils::RAILS_TO_GQL_TYPE_MAP[f.type]
          field f.name, field_gql_type
        end
      end

      # Cache the processed class here to prevent infinite recursion
      RailsFields.processed_classes[self] = type

      type.instance_eval do
        owner_self.reflections.each do |association_name, reflection|
          if reflection.macro == :has_many
            reflection_klass = if reflection.options[:through]
              through_reflection_klass = reflection.through_reflection.klass
              source_reflection_name = reflection.source_reflection_name.to_s
              source_reflection = through_reflection_klass.reflections[source_reflection_name]
              source_reflection ? source_reflection.klass : through_reflection_klass
            else
              reflection.klass
            end
            field association_name, [reflection_klass.gql_type], null: true
          elsif reflection.macro == :belongs_to
            field association_name, reflection.klass.gql_type, null: true
          end
        end

        type
      end
    end

    def enforce_declared_fields
      database_columns = column_names.map(&:to_sym)
      declared_fields_names = declared_fields.map(&:name).map(&:to_sym) || []
      changes = RailsFields::Utils.detect_changes(self)
      migration = RailsFields::Utils.generate_migration(self, changes)
      instance_methods = self.instance_methods(false).select do |method|
        instance_method(method).source_location.first.start_with?(Rails.root.to_s)
      end
      extra_methods = instance_methods - declared_fields_names.map(&:to_sym)
      has_changes = !changes.nil?

      unless extra_methods.empty?
        # TODO: Custom error subclass
        raise "You have extra methods declared in #{name}: #{extra_methods.join(', ')}. Please remove them or declare them as fields."
      end

      if has_changes
        error_message = <<~STRING

          ----------------

          Declared Fields:
          #{declared_fields_names.join(', ')}

          Database columns:
          #{database_columns.join(', ')}

          Changes:
          #{changes.to_yaml.lines[1..-1].join}
          Migration:
          #{migration}

          ----------------
        STRING
        raise Errors::RailsFieldsMismatchError.new(error_message)
      end
    end
  end
end
