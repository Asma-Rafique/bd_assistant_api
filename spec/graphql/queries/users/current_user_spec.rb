require "rails_helper"

RSpec.describe "currentUser", type: :graphql do
  let(:query) { "{ currentUser { id email fullName } }" }

  it "returns the signed-in user" do
    user = create(:user, first_name: "Sam", last_name: "Lee")

    result = execute_graphql(query, as: user)

    expect(result.dig("data", "currentUser"))
      .to eq("id" => user.id.to_s, "email" => user.email, "fullName" => "Sam Lee")
  end

  it "is rejected when signed out" do
    expect(error_codes(execute_graphql(query))).to eq(["UNAUTHENTICATED"])
  end
end
