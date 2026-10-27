require "rails_helper"

RSpec.describe "fetchUser", type: :graphql do
  let(:query) { "query($id: ID!) { fetchUser(id: $id) { id email } }" }
  let(:team_member) { create(:user) }
  let(:other_user) { create(:user) }

  def fetch(id, as:) = execute_graphql(query, variables: { id: id.to_s }, as:)

  it "returns the caller's own account" do
    result = fetch(team_member.id, as: team_member)

    expect(result.dig("data", "fetchUser", "id")).to eq(team_member.id.to_s)
  end

  it "lets a super admin fetch anyone" do
    result = fetch(other_user.id, as: create(:user, :super_admin))

    expect(result.dig("data", "fetchUser", "email")).to eq(other_user.email)
  end

  it "hides someone else's account from a team member as NOT_FOUND" do
    result = fetch(other_user.id, as: team_member)

    expect(error_codes(result)).to eq(["NOT_FOUND"])
  end

  it "answers an unknown id with NOT_FOUND" do
    expect(error_codes(fetch(0, as: team_member))).to eq(["NOT_FOUND"])
  end
end
