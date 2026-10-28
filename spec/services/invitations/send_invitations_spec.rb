require "rails_helper"

RSpec.describe Invitations::SendInvitations do
  let(:admin) { create(:user, :super_admin) }

  def invite(emails, role: "team_member")
    described_class.call(emails:, role:, invited_by: admin)
  end

  it "creates a pending user for each address and emails each one" do
    result = nil

    expect { result = invite(["Ana@Example.com ", "ben@example.com", "ana@example.com"]) }
      .to have_enqueued_mail(InvitationMailer, :invitation).twice

    expect(result.value.map(&:email)).to contain_exactly("ana@example.com", "ben@example.com")
    expect(result.value).to all(be_invitation_pending)
    expect(result.value.map(&:invited_by)).to all(eq(admin))
  end

  it "invites nobody when one address already has an account" do
    create(:user, email: "taken@example.com")

    result = invite(["new@example.com", "taken@example.com"])

    expect(result.error.message).to eq("These emails already have an account: taken@example.com.")
    expect(User.exists?(email: "new@example.com")).to be(false)
  end

  it "invites nobody when one address is malformed" do
    result = invite(["new@example.com", "not-an-email"])

    expect(result.error.field_errors.pluck("field")).to eq(["email"])
    expect(User.exists?(email: "new@example.com")).to be(false)
  end

  it "rejects an empty list and more than 20 addresses" do
    too_many = Array.new(21) { "person#{it}@example.com" }

    expect(invite([]).error.code).to eq(:validation_failed)
    expect(invite(too_many).error.code).to eq(:validation_failed)
  end
end
