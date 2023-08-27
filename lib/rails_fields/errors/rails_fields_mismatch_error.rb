module RailsFields
  module Errors
    class RailsFieldsMismatchError < RailsFieldsError
      include ActiveSupport::ActionableError

      action "Save migrations" do
        models = RailsFields::Utils.active_record_models
        models.each_with_index do |m, index|
          m.write_migration(index:)
        end
      end

      # action "Run db:migrations" do
      #   ActiveRecord::Tasks::DatabaseTasks.migrate
      # end
    end
  end
end
