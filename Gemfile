source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.4"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[windows jruby]

# Use the database-backed adapters for Rails.cache and Action Cable
gem "solid_cable"
gem "solid_cache"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]

gem "action_policy", "~> 0.7" # permissions, same as saas-api

gem "bcrypt", "~> 3.1"

gem "graphql", "~> 2.6" # the GraphQL API

gem "rack-attack", "~> 6.8" # per-IP request limits
# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
gem "rack-cors", "~> 3.0"
gem "redis", "~> 5.4" # Rails.cache in production (rate-limit counters)
gem "sidekiq", "~> 8.1" # background jobs, such as sending email; needs Redis
gem "strong_migrations", "~> 2.8"

gem "pagy", "~> 43.7" # pagination for list queries
group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "bundler-audit", require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "bullet", "~> 8.3"
  gem "dotenv-rails", "~> 3.1"
  gem "factory_bot_rails", "~> 6.5"
  gem "rspec-rails", "~> 8.0"
  gem "rubocop", require: false
  gem "rubocop-factory_bot", require: false
  gem "rubocop-graphql", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-rspec_rails", require: false
end

group :development do
  gem "letter_opener_web", "~> 3.0"
end
