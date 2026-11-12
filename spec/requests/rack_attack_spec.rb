require "rails_helper"

RSpec.describe "Rack::Attack" do
  # Rack::Attack counts in clock-aligned minutes; frozen time keeps all the
  # requests in one window, or the count restarts if a minute ticks over.
  before { freeze_time }

  it "answers 429 RATE_LIMITED after 300 requests a minute from one IP" do
    300.times { post "/graphql", params: { query: "{ apiStatus }" } }

    post "/graphql", params: { query: "{ apiStatus }" }

    expect(response).to have_http_status(:too_many_requests)
    expect(response.parsed_body.dig("errors", 0, "extensions", "code")).to eq("RATE_LIMITED")
  end
end
