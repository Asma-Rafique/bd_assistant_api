require "rails_helper"

RSpec.describe "createInvitation", type: :graphql do
  let(:mutation) do
    <<~GQL
      mutation($emails: [String!]!, $role: UserRoleEnum!) {
        createInvitation(input: { emails: $emails, role: $role }) { message users { email role invitationPending } }
      }
    GQL
  end

  def create_invitation(as:, emails: ["new@example.com"], role: "team_member")
    execute_graphql(mutation, variables: { emails:, role: }, as:)
  end

  it "lets a super admin invite people" do
    data = create_invitation(as: create(:user, :super_admin)).dig("data", "createInvitation")

    expect(data["message"]).to eq("Invitation sent.")
    expect(data["users"])
      .to eq([{ "email" => "new@example.com", "role" => "team_member", "invitationPending" => true }])
  end

  it "is FORBIDDEN for a team member" do
    expect(error_codes(create_invitation(as: create(:user)))).to eq(["FORBIDDEN"])
    expect(User.exists?(email: "new@example.com")).to be(false)
  end

  it "answers VALIDATION_FAILED when an email is taken" do
    create(:user, email: "new@example.com")

    expect(error_codes(create_invitation(as: create(:user, :super_admin)))).to eq(["VALIDATION_FAILED"])
  end
end
