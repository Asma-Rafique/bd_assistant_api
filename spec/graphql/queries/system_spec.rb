require "rails_helper"

RSpec.describe "System queries", type: :graphql do
  describe "apiStatus" do
    it "returns ok without a login" do
      result = execute_graphql("{ apiStatus }")

      expect(result.dig("data", "apiStatus")).to eq("ok")
    end
  end

  describe "protectedPing" do
    it "is rejected when signed out" do
      result = execute_graphql("{ protectedPing }")

      expect(error_codes(result)).to eq(["UNAUTHENTICATED"])
      expect(result["data"]).to be_nil
    end
  end
end
