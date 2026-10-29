require "rails_helper"

RSpec.describe WebMock do
  it "stops specs from reaching a real API" do
    expect { Net::HTTP.get(URI("https://api.anthropic.com/v1/models")) }
      .to raise_error(WebMock::NetConnectNotAllowedError)
  end

  it "answers a stubbed request" do
    stub_request(:get, "https://api.anthropic.com/v1/models").to_return(body: "stubbed")

    expect(Net::HTTP.get(URI("https://api.anthropic.com/v1/models"))).to eq("stubbed")
  end
end
