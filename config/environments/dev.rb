require "active_support/core_ext/integer/time"

# The dev environment: a server in AWS where the team tries the newest work,
# run with RAILS_ENV=dev (deploy/dev). Not to be confused with development,
# which is a laptop. It behaves like production; the differences are email
# settings read from the server's .env and deprecations shown in the log.
Rails.application.configure do
  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Thruster terminates TLS in front of Puma (TLS_DOMAIN in deploy/dev/compose.yml).
  config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Skip http-to-https redirect for the default health check endpoint.
  config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [:request_id]
  config.logger   = ActiveSupport::TaggedLogging.logger($stdout)

  # Change to "debug" to log everything (including potentially personally-identifiable information!).
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Unlike production, deprecations are logged, so they show up on dev before
  # an upgrade turns them into errors.
  config.active_support.deprecation = :log

  # Redis, so every server process shares one set of rate-limit counters.
  config.cache_store = :redis_cache_store, config.x.redis

  # Host for URLs built in mailers: this server's name.
  config.action_mailer.default_url_options = { host: ENV.fetch("APP_HOST") }

  # Email goes out through Amazon SES's SMTP interface; the credentials live in
  # the server's deploy/dev/.env, never in the repo.
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: ENV.fetch("SMTP_ADDRESS", nil),
    port: ENV.fetch("SMTP_PORT", 587).to_i,
    user_name: ENV.fetch("SMTP_USERNAME", nil),
    password: ENV.fetch("SMTP_PASSWORD", nil),
    authentication: :login,
    enable_starttls_auto: true
  }

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections.
  config.active_record.attributes_for_inspect = [:id]

  # Enable DNS rebinding protection and other `Host` header attacks.
  config.hosts = ENV.fetch("ALLOWED_HOSTS").split(",").map(&:strip)

  # Skip DNS rebinding protection for the default health check endpoint.
  config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end
