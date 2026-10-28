require "rails_helper"

RSpec.describe Invitations::ResendInvitation do
  it "emails a new link and makes the old one stop working" do
    user = create(:user, :invited, invitation_sent_at: 1.hour.ago)
    old_token = user.generate_token_for(:invitation)

    expect { described_class.call(user:) }.to have_enqueued_mail(InvitationMailer, :invitation)
    expect(User.find_by_invitation_token(old_token)).to be_nil
  end
end
