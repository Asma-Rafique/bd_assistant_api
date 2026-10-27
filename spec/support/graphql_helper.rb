module GraphqlHelper
  # Runs the real schema. Pass `as:` (a user) or `session:` to run as a
  # signed-in caller; nothing about authentication is stubbed.
  def execute_graphql(query, variables: {}, as: nil, session: nil)
    session ||= create(:session, user: as) if as
    BdAssistantApiSchema.execute(
      query,
      variables:,
      context: { current_session: session, current_user: session&.user, ip_address: "127.0.0.1" }
    ).to_h
  end

  # The extensions.code of each error, the part of the error that's the API contract.
  def error_codes(result) = result.fetch("errors", []).map { it.dig("extensions", "code") }
end

RSpec.configure do |config|
  config.include GraphqlHelper, type: :graphql
end
