module GraphqlHelper
  # Runs the real schema, signed out. B4 adds an `as:` option to run as a user.
  def execute_graphql(query, variables: {})
    BdAssistantApiSchema.execute(
      query, variables:, context: { current_user: nil, ip_address: "127.0.0.1" }
    ).to_h
  end

  # The extensions.code of each error, the part of the error that's the API contract.
  def error_codes(result) = result.fetch("errors", []).map { it.dig("extensions", "code") }
end

RSpec.configure do |config|
  config.include GraphqlHelper, type: :graphql
end
