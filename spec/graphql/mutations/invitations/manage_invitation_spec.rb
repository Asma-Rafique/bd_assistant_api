require "rails_helper"

RSpec.describe "resendInvitation and deleteInvitation", type: :graphql do
  let(:admin) { create(:user, :super_admin) }
  let(:invited) { create(:user, :invited) }

  def resend(user, as: admin)
    execute_graphql(<<~GQL, variables: { id: user.id.to_s }, as:)
      mutation($id: ID!) { resendInvitation(input: { id: $id }) { user { email } } }
    GQL
  end

  def delete(user, as: admin)
    execute_graphql(<<~GQL, variables: { id: user.id.to_s }, as:)
      mutation($id: ID!) { deleteInvitation(input: { id: $id }) { message } }
    GQL
  end

  it "resends a pending invitation" do
    expect { resend(invited) }.to have_enqueued_mail(InvitationMailer, :invitation)
  end

  it "deletes a pending invitation and its account" do
    expect(delete(invited).dig("data", "deleteInvitation", "message")).to eq("Invitation deleted.")
    expect(User.exists?(invited.id)).to be(false)
  end

  it "is FORBIDDEN for a user who already accepted" do
    member = create(:user)

    expect(error_codes(delete(member))).to eq(["FORBIDDEN"])
    expect(error_codes(resend(member))).to eq(["FORBIDDEN"])
    expect(User.exists?(member.id)).to be(true)
  end

  it "hides invitations from a team member as NOT_FOUND" do
    expect(error_codes(delete(invited, as: create(:user)))).to eq(["NOT_FOUND"])
  end
end
