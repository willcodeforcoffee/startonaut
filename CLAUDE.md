# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Startonaut is a Rails 8 bookmark manager / personal start page: bookmarks with automatic favicon
downloading, tag management, and Netscape bookmark import/export. SQLite is used for everything
(dev/test/production), via the Solid* stack (solid_cache, solid_queue, solid_cable).

## Development Commands

Ruby/Node versions are pinned via `mise.toml` (Ruby 4.0.6, Node 24); env vars load from `.env`
(copy from `.env.example` first — see README for details).

```bash
bin/dev                            # Starts Rails, Tailwind watcher, and job processor (via overmind, Procfile.dev), port 6250
bin/rails server                   # Rails server alone
bin/rails tailwindcss:watch        # Tailwind watcher alone
bin/jobs                           # Background job processor (Solid Queue) alone
```

In development, requests are force-redirected to `startonaut.localhost:6250` (see
`ApplicationController#ensure_development_host`) — use that host, not `localhost`.

### Testing

RSpec + FactoryBot.

```bash
bundle exec rspec                        # Full suite
bundle exec rspec spec/models/bookmark_spec.rb          # Single file
bundle exec rspec spec/models/bookmark_spec.rb:42        # Single example at line 42
```

### Linting / Static Analysis

```bash
bin/rubocop         # Omakase Ruby style (rubocop-rails-omakase)
bin/brakeman         # Security static analysis
```

### Deployment (Kamal)

Deploy config is generated (not committed) from `.env` values via a rake task, to keep the project
self-hostable:

```bash
bin/rails deploy:generate_config    # Generates config/deploy.yml from .env
bin/rails deploy:show_env_vars      # Show which env vars will be used
```

## Architecture

### Authentication

Session-based, cookie-signed (not Devise). `Authentication` concern (`app/controllers/concerns/authentication.rb`)
is included in `ApplicationController` and requires authentication on every action by default.
- `Current.session` holds the current session (thread-safe, via `ActiveSupport::CurrentAttributes`).
- Use `allow_unauthenticated_access(**options)` (class method) in a controller to skip the
  `require_authentication` before_action, e.g. for sign-in/registration pages.
- `start_new_session_for(user)` / `terminate_session` create/destroy `Session` records tied to
  `cookies.signed.permanent[:session_id]`.

### Core Models

```ruby
User -> has_many :bookmarks, :sessions, :tags
Bookmark -> belongs_to :user; has_and_belongs_to_many :tags
Tag -> belongs_to :user; has_and_belongs_to_many :bookmarks
```

- `Bookmark#tag_list=` accepts a comma-separated string, splitting/downcasing/`find_or_create_by`-ing
  tags scoped to the bookmark's user; `#tag_list` / `#tag_list_no_spaces` return the joined string
  back for form editing.
- `Bookmark` normalizes `url`/`feed_url` (strip + downcase) and validates URL format via
  `URI::DEFAULT_PARSER.make_regexp`.
- `Tag` defines `USER_DEFAULT_TAGS` (read later + each day of the week); new users get these
  auto-created asynchronously via `CreateDefaultUserTagsJob` (triggered from `User#after_create`).
- `Bookmark#after_create` enqueues `DownloadFaviconsJob` to fetch favicon/apple-touch-icon
  asynchronously (stored via ActiveStorage as `bookmark.icon` / `bookmark.apple_touch_icon`).

### Feature Flags

Simple env-var-backed flags in `app/models/feature_flag.rb` (e.g. `FeatureFlag.enable_new_user_registration?`),
not a database/admin-driven flag system. Add new flags the same way if needed.

### Services

`app/services/`, errors raised as `ServiceError` (base class in `service_error.rb`).
- `DownloadWebpageService` — HTTP fetch with error handling, used by favicon/import logic.
- `BookmarkHtmlParser` — extracts favicon/metadata from a fetched page.
- `NetscapeBookmarksImport` — parses Netscape-format bookmark export HTML; returns
  `[imported, duplicates, errors]` arrays for user-facing import feedback.

### Forms

`ThemedFormBuilder` (`app/helpers/themed_form_builder.rb`) is the app-wide default form builder
(set via `default_form_builder ThemedFormBuilder` in `ApplicationController`), providing
Tailwind-styled inputs/errors and submit button variants (`:primary`, `:danger`, `:secondary`).
Use it (implicitly, via `form_with`) rather than ad hoc markup for consistent styling.

### Frontend

Import maps (no bundler/Webpack/Vite) + Tailwind CSS + Hotwire (Turbo + Stimulus). Stimulus
controllers live in `app/javascript/controllers`.

### Notable Routes/Controllers

- `bookmarks#fetch_remote_bookmark` — server-side preview fetch when adding a bookmark by URL.
- `bookmarks_favicon_proxy` (nested under `bookmarks`) — serves/proxies cached favicon images.
- `tags#search` — tag autocomplete endpoint.
- `pages#search` — search across pages (bookmarks/tags).
- `import_bookmarks` — Netscape HTML bookmark import flow.
- `export_bookmarks` — bookmark export flow.
