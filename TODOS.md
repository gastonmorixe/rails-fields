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
