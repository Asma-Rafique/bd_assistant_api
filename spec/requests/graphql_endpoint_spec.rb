require "rails_helper"

RSpec.describe "POST /graphql" do
  let(:allowed_origin) { Rails.configuration.x.cors_allowed_origins.first }

  def json = response.parsed_body

  it "answers malformed variables with 400 BAD_REQUEST" do
    post "/graphql", params: { query: "{ apiStatus }", variables: "{not json" }

    expect(response).to have_http_status(:bad_request)
    expect(json.dig("errors", 0, "extensions", "code")).to eq("BAD_REQUEST")
  end

  describe "authentication" do
    let(:query) { { query: "{ currentUser { id } }" } }
    let(:session) { create(:session) }

    def post_graphql(headers = {})
      post "/graphql", params: query.to_json, headers: { "Content-Type" => "application/json", **headers }
    end

    it "accepts a bearer token" do
      post_graphql("Authorization" => "Bearer #{session.token}")

      expect(json.dig("data", "currentUser", "id")).to eq(session.user_id.to_s)
    end

    it "treats an unknown token as signed out" do
      post_graphql("Authorization" => "Bearer not-a-real-token")

      expect(json.dig("errors", 0, "extensions", "code")).to eq("UNAUTHENTICATED")
    end

    it "treats an archived user's token as signed out" do
      session.user.update!(archived_at: Time.current)

      post_graphql("Authorization" => "Bearer #{session.token}")

      expect(json.dig("errors", 0, "extensions", "code")).to eq("UNAUTHENTICATED")
    end
  end

  describe "CORS" do
    it "allows the configured frontend origin" do
      options "/graphql", headers: { "Origin" => allowed_origin, "Access-Control-Request-Method" => "POST",
                                     "Access-Control-Request-Headers" => "authorization, content-type" }

      expect(response.headers["Access-Control-Allow-Origin"]).to eq(allowed_origin)
    end

    it "does not allow any other origin" do
      options "/graphql", headers: { "Origin" => "https://evil.example", "Access-Control-Request-Method" => "POST" }

      expect(response.headers["Access-Control-Allow-Origin"]).to be_nil
    end
  end
end
