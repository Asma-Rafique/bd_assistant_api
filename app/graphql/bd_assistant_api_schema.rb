# frozen_string_literal: true

class BdAssistantApiSchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)

  # For batch-loading (see https://graphql-ruby.org/dataloader/overview.html)
  use GraphQL::Dataloader
  use GraphQL::Schema::Timeout, max_seconds: 10

  # Limit the depth and size of incoming queries:
  max_depth 12
  max_query_string_tokens(5000)

  # Stop validating when it encounters this many errors:
  validate_max_errors 25

  max_complexity(300)
  default_max_page_size(100)

  # A record lookup like User.find(99) failed: tell the client "not found".
  rescue_from(ActiveRecord::RecordNotFound) { raise GraphqlErrors.not_found }

  # A policy said no: the caller is signed in but not allowed.
  rescue_from(ActionPolicy::Unauthorized) { raise GraphqlErrors.forbidden }

  rescue_from(ActiveRecord::RecordInvalid) do |error|
    raise GraphqlErrors.from_service_error(ServiceError.from_record(error.record))
  end

  # Any other unexpected error.
  rescue_from(StandardError) do |error|
    raise error if Rails.env.local?

    Rails.error.report(error, handled: true)
    raise GraphqlErrors.internal
  end

  disable_introspection_entry_points unless ENV.fetch("GRAPHQL_INTROSPECTION", Rails.env.local?.to_s) == "true"
end
