# Repository Guidelines

## Project Structure & Module Organization
- `lib/rails_fields/`: core gem code (class/instance methods, middleware, utils).
- `lib/rails-fields.rb` and `lib/rails/fields.rb`: gem entry points and autoload shim.
- `docs/` and `assets/`: documentation site and static assets.
- Root files: `rails_fields.gemspec`, `Gemfile`, `.rubocop.yml`, `Makefile`.

## Build, Test, and Development Commands
- Install deps: `bundle install`
- Lint: `bundle exec rubocop`
- Build gem: `gem build rails_fields.gemspec`
- Docs (YARD): `make yard` (or `bundle exec yard doc`)
- Optional helpers: `make rubocop-generate` to refresh RuboCop TODO.

Note: This repo currently has no automated test suite. Validate changes in a Rails app that includes the gem.

## Coding Style & Naming Conventions
- Ruby style: 2‑space indentation, snake_case methods, CamelCase classes/modules.
- Linting: RuboCop configured via `.rubocop.yml` and `.rubocop_todo.yml`. Run before pushing.
- File layout: keep public APIs under `lib/rails_fields/`; avoid one‑off utilities outside `Utils`.
- Avoid introducing hard runtime dependencies; guard optional integrations (e.g., GraphQL).

## Architecture Overview
- Railtie: `RailsFields::Railtie` extends ActiveRecord models with `ClassMethods` and injects `EnforceFieldsMiddleware` after `ActiveRecord::Migration::CheckPending`.
- Declaration: Models call `field :name, :type` to build `DeclaredField` entries, validated against `ActiveRecord::Base.connection.native_database_types`.
- Enforcement: On each request, middleware iterates `ApplicationRecord.descendants` and calls `enforce_declared_fields`.
- Diffing: `Utils.detect_changes(model)` compares `declared_fields` to `model.attribute_types` and reflections to compute `added`, `removed`, `renamed`, `type_changed`, and association deltas.
- Migration: `Utils.generate_migration` renders migration code; `write_migration` writes to `db/migrate/<timestamp>_*.rb`. Actionable error “Save migrations” triggers this for all models.
- GraphQL (optional): `gql_type` builds a GraphQL type per model using `Utils::RAILS_TO_GQL_TYPE_MAP` and AR reflections; cached in `RailsFields.processed_classes`. Guards if GraphQL is absent.

## Testing Guidelines
- Until tests exist, reproduce and verify in a sample Rails app:
  1) Declare a field, e.g. `field :age, :integer`.
  2) Hit an endpoint to trigger enforcement; confirm migration text and "save migration" flow.
- Prefer adding minimal fixtures over broad refactors. If adding tests, use RSpec and place files under `spec/` (pending introduction).

## Commit & Pull Request Guidelines
- Commits: concise, imperative. Prefer Conventional Commits where sensible, e.g.:
  - `fix(utils): handle nil reflections in migrations`
  - `feat: add DeclaredField struct options`
- PRs must include:
  - Summary, rationale, and scope of change.
  - Repro steps and before/after behavior.
  - Any migration or configuration notes.
  - Screenshots/logs when relevant.

## Security & Configuration Tips
- Never include secrets in code or docs.
- Handle DB adapter differences via `ActiveRecord` APIs; avoid adapter‑specific SQL unless wrapped.
