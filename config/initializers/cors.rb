# Be sure to restart your server when you modify this file.

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*Rails.configuration.x.cors_allowed_origins)

    resource "/graphql",
             methods: %i[post options],
             headers: %w[Authorization Content-Type Accept],
             credentials: false,
             max_age: 2.hours.to_i
  end
end
