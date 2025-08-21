# Change Log
All notable changes to this project will be documented in this file.
 
The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).
 
## [Unreleased] - yyyy-mm-dd
 
Here we write upgrading notes for brands. It's a team effort to make them as
straightforward as possible.
 
### Added
- [PROJECTNAME-XXXX](http://tickets.projectname.com/browse/PROJECTNAME-XXXX)
  MINOR Ticket title goes here.
- [PROJECTNAME-YYYY](http://tickets.projectname.com/browse/PROJECTNAME-YYYY)
  PATCH Ticket title goes here.
 
### Changed
 
### Fixed

## [0.3.3] - 2025-08-21

### Added
- Dummy Rails app with Minitest suite for internal testing
- Rake test task and default `rake test`

### Changed
- Railtie: update middleware insertion for Rails 8 (fallback to `use` when `ActiveRecord::Migration::CheckPending` is absent)
- Utils.detect_changes: ignore model primary key in diffs; normalize type matching; improve rename detection

### Fixed
- False-positive removal of primary key (e.g., `:id`) from detected changes
- Rename detection failing when comparing type hashes vs. symbols
- Middleware insertion error on Rails 8 trying to insert after removed `CheckPending`
- Ignore `*.log` files across the repo

## [1.2.4] - 2017-03-15
  
Here we would have the update steps for 1.2.4 for people to follow.
 
### Added
 
### Changed
  
- [PROJECTNAME-ZZZZ](http://tickets.projectname.com/browse/PROJECTNAME-ZZZZ)
  PATCH Drupal.org is now used for composer.
 
### Fixed
 
- [PROJECTNAME-TTTT](http://tickets.projectname.com/browse/PROJECTNAME-TTTT)
  PATCH Add logic to runsheet teaser delete to delete corresponding
  schedule cards.
 
## [1.2.3] - 2017-03-14
 
### Added
   
### Changed
 
### Fixed
 
- [PROJECTNAME-UUUU](http://tickets.projectname.com/browse/PROJECTNAME-UUUU)
  MINOR Fix module foo tests
- [PROJECTNAME-RRRR](http://tickets.projectname.com/browse/PROJECTNAME-RRRR)
  MAJOR Module foo's timeline uses the browser timezone for date resolution 
