# TODOs

## Middleware insertion robustness
- Problem: Railtie inserts after `ActiveRecord::Migration::CheckPending`, which may not exist in some Rails stacks, causing initialization errors.
- Impact: Boot-time failure when the target middleware is absent.
- Proposed change: In `initializer "rails_fields.middleware"`, insert after `ActiveRecord::Migration::CheckPending` only if defined; otherwise `use RailsFields::EnforceFieldsMiddleware`.
- Notes: Confirm supported Rails versions and preferred middleware order before changing.
- Status: TODO (defer implementation)

