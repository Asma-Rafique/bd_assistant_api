# A coarse per-IP limit at the edge, before Rails parses anything. The tighter
# limits for login, resets and invitations are declared on the operations
# (GraphqlOperation.rate_limit), because every request posts to /graphql and
# only the GraphQL layer knows which operation it is.
module Rack
  class Attack
    throttle("graphql/ip", limit: 300, period: 1.minute) do |request|
      request.ip if request.path == "/graphql"
    end

    self.throttled_responder = lambda do |_request|
      body = { errors: [{ message: I18n.t("errors.rate_limited"), extensions: { code: "RATE_LIMITED" } }] }
      [429, { "Content-Type" => "application/json" }, [body.to_json]]
    end
  end
end
