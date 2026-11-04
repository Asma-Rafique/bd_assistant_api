require "rails_helper"

RSpec.describe InvitationMailer do
  describe "#invitation" do
    let(:admin) { create(:user, :super_admin, first_name: "Ana", last_name: "Diaz") }
    let(:user) { create(:user, :invited, email: "new@example.com", invited_by: admin) }
    let(:mail) { described_class.with(user:).invitation }

    it "goes to the invited user and names who invited them" do
      expect(mail.to).to eq(["new@example.com"])
      expect(mail.subject).to eq("You're invited to BD Assistant")
      expect(mail.text_part.body.to_s).to include("Ana Diaz invited you")
    end

    it "links to the frontend with a token that finds the user" do
      token = mail.text_part.body.to_s[%r{/accept-invitation\?token=(\S+)}, 1]

      expect(User.find_by_invitation_token(CGI.unescape(token))).to eq(user)
    end
  end
end
