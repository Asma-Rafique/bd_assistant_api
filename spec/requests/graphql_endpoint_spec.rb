require "rails_helper"

RSpec.describe "POST /graphql" do
  let(:allowed_origin) { Rails.configuration.x.cors_allowed_origins.first }

  def json = response.parsed_body

  it "answers malformed variables with 400 BAD_REQUEST" do
    post "/graphql", params: { query: "{ apiStatus }", variables: "{not json" }

    expect(response).to have_http_status(:bad_request)
    expect(json.dig("errors", 0, "extensions", "code")).to eq("BAD_REQUEST")
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
