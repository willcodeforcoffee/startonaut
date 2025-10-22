# GitHub Copilot Instructions for Startonaut

## Project Overview
Startonaut is a Rails 8 bookmark manager with favicon downloading, tag management, and Netscape bookmark import. It's designed as a personal start page application with modern Rails features.

## Architecture & Key Components

### Authentication Pattern
- Uses **session-based auth** via `Authentication` concern in `app/controllers/concerns/`
- Controllers inherit `include Authentication` from `ApplicationController`
- Current user accessible via `Current.session` (thread-safe context)
- Skip authentication with `allow_unauthenticated_access` class method

### Core Models & Relationships
```ruby
# Key relationships to maintain
User -> has_many :bookmarks, :sessions, :tags
Bookmark -> belongs_to :user; has_and_belongs_to_many :tags
Tag -> belongs_to :user; has_and_belongs_to_many :bookmarks

# Virtual attributes for tag handling
bookmark.tag_list = "ruby, rails, programming" # comma-separated string
bookmark.tag_list # returns joined string of tag names
```

### Solid* Stack (Rails 8 Defaults)
- **solid_cache**, **solid_queue**, **solid_cable** for caching, jobs, and ActionCable
- Job processing runs in separate process: `bin/jobs` (see `Procfile.dev`)
- SQLite database for everything (dev/test/production)

### Form Building Pattern
- **Custom form builder**: `ThemedFormBuilder` with Tailwind CSS integration
- Set as default: `default_form_builder ThemedFormBuilder` in `ApplicationController`
- Provides styled inputs, error handling, and consistent theme classes
- Submit button styles: `:primary`, `:danger`, `:secondary`

## Development Workflow

### Environment Setup
```bash
# Uses mise.toml for Ruby/Node version management
cp .env.example .env  # Required first step
bin/dev               # Starts Rails, Tailwind watcher, and job processor
```

### Deployment (Kamal)
```bash
# Generate deployment config from template
bin/rails deploy:generate_config
bin/rails deploy:show_env_vars  # Check environment variables
```

### Testing
- **RSpec** test suite with FactoryBot
- Authentication helpers in `spec/support/authentication_support.rb`
- Run with standard `rspec` or `bin/rails spec`

## Key Service Objects & Jobs

### Favicon Management
- `DownloadFaviconsJob` handles asynchronous icon fetching after bookmark creation
- `DownloadWebpageService` for HTTP requests with error handling
- Supports both regular favicons and Apple touch icons with size prioritization
- Uses ActiveStorage attachments: `bookmark.icon`, `bookmark.apple_touch_icon`

### Import System
- `NetscapeBookmarksImport` service for parsing HTML bookmark exports
- Handles duplicate detection and tag assignment from import files
- Returns arrays: `imported, duplicates, errors` for user feedback

## Rails Conventions & Patterns

### URL Normalization
```ruby
# Bookmark model normalizes URLs automatically
normalizes :url, with: ->(e) { e.strip.downcase }
normalizes :feed_url, with: ->(e) { e&.strip&.downcase }
```

### Modern Rails Features
- **Import maps** for JavaScript (not Webpack/Vite)
- **Tailwind CSS** via `tailwindcss-rails` gem
- **Hotwire/Turbo** for SPA-like interactions
- **ActiveStorage** for file attachments (favicons)

### Controller Patterns
- Favicon proxy: `BookmarksFaviconProxyController` serves cached icons
- Remote bookmark fetching: `bookmarks#fetch_remote_bookmark` for URL previews  
- Tag search: `tags#search` for autocomplete functionality

## File Organization
- Services in `app/services/` with `ServiceError` base exception class
- Custom form builder in `app/helpers/themed_form_builder.rb`
- Rake tasks in `lib/tasks/` for deployment config generation
- Specs mirror `app/` structure with factories in `spec/factories/`

## Development Commands
```bash
bin/dev                    # Start development server (port 6250)
bin/rails deploy:generate_config  # Generate Kamal deploy config
bin/jobs                   # Run background job processor
bin/rails tailwindcss:watch       # Watch Tailwind changes
```

When working on this codebase, maintain the session-based auth pattern, use the custom form builder for consistency, and follow the service object pattern for complex business logic.