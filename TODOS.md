# TODOs

## Middleware insertion robustness
- Problem: Railtie inserts after `ActiveRecord::Migration::CheckPending`, which may not exist in some Rails stacks, causing initialization errors.
- Impact: Boot-time failure when the target middleware is absent.
- Proposed change: In `initializer "rails_fields.middleware"`, insert after `ActiveRecord::Migration::CheckPending` only if defined; otherwise `use RailsFields::EnforceFieldsMiddleware`.
- Notes: Confirm supported Rails versions and preferred middleware order before changing.
- Status: TODO (defer implementation)

## Guard source_location usage in enforcement
- Problem: `instance_method(method).source_location.first` may be nil for C-defined methods.
- Impact: Possible NoMethodError during enforcement when encountering methods without Ruby source.
- Proposed change: In `enforce_declared_fields`, capture `loc = instance_method(method).source_location` and ensure `loc && loc.first.start_with?(Rails.root.to_s)`.
- Status: TODO (defer implementation)

## Explicit require for ActiveSupport::ActionableError
- Problem: `RailsFields::Errors::RailsFieldsMismatchError` includes `ActiveSupport::ActionableError` without requiring it explicitly.
- Impact: Potential NameError in environments that don't autoload all ActiveSupport modules.
- Proposed change: Add `require 'active_support/actionable_error'` at the top of `lib/rails_fields/errors/rails_fields_mismatch_error.rb`.
- Status: TODO (defer implementation)

## Fix rename detection logic in `detect_changes`
- Problems:
  - `added[:type]` is a hash while `removed[:type]` is a symbol; direct comparison fails.
  - One-to-one rename validation compares types to names.
- Proposed change:
  - Compare `added[:type][:name]` to `removed[:type]` when identifying potential renames.
  - Validate one-to-one by field names; adjust rejections accordingly.
- Status: TODO (defer implementation)
