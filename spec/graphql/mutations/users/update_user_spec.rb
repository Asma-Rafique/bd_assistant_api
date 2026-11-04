require "rails_helper"

RSpec.describe "updateUser", type: :graphql do
  let(:mutation) do
    <<~GQL
      mutation($id: ID, $attributes: UserAttributesInput!) {
        updateUser(input: { id: $id, userAttributes: $attributes }) { user { id firstName } }
      }
    GQL
  end
  let(:team_member) { create(:user) }
  let(:other_user) { create(:user) }

  def update_user(as:, id: nil) = execute_graphql(mutation, variables: { id:, attributes: { firstName: "Noor" } }, as:)

  it "updates the caller's own profile when id is left out" do
    expect(update_user(as: team_member).dig("data", "updateUser", "user", "firstName")).to eq("Noor")
    expect(team_member.reload.first_name).to eq("Noor")
  end

  it "lets a super admin update someone else" do
    update_user(as: create(:user, :super_admin), id: other_user.id.to_s)

    expect(other_user.reload.first_name).to eq("Noor")
  end

  it "hides someone else's account from a team member as NOT_FOUND" do
    expect(error_codes(update_user(as: team_member, id: other_user.id.to_s))).to eq(["NOT_FOUND"])
    expect(other_user.reload.first_name).to eq("Sam")
  end
end
