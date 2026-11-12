require "rails_helper"

RSpec.describe "Onboarding", type: :graphql do
  let(:user) { create(:user, first_name: nil, last_name: nil) }
  let(:query) do
    "{ currentUser { onboarding { required completed currentStep steps { step position completed missingFields } } } }"
  end

  def onboarding = execute_graphql(query, as: user).dig("data", "currentUser", "onboarding")

  it "shows a user without a name where to continue" do
    expect(onboarding).to eq(
      "required" => true, "completed" => false, "currentStep" => "step1",
      "steps" => [{ "step" => "step1", "position" => 1, "completed" => false,
                    "missingFields" => %w[firstName lastName] }]
    )
  end

  it "is completed after updateUser saves the names" do
    execute_graphql(<<~GQL, as: user)
      mutation { updateUser(input: { userAttributes: { firstName: "Sam", lastName: "Lee" } }) { user { id } } }
    GQL

    expect(onboarding).to include("completed" => true, "currentStep" => nil)
  end
end
