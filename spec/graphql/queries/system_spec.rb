require "rails_helper"

RSpec.describe "System queries", type: :graphql do
  describe "apiStatus" do
    it "returns ok without a login" do
      result = execute_graphql("{ apiStatus }")

      expect(result.dig("data", "apiStatus")).to eq("ok")
    end
  end
end
