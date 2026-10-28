require "rails_helper"

RSpec.describe Auth::RequestPasswordReset do
  it "queues a reset email for an existing account" do
    user = create(:user, email: "sam@example.com")

    expect { described_class.call(email: "SAM@example.com") }
      .to have_enqueued_mail(UserMailer, :password_reset).with(params: { user: }, args: [])
  end

  it "succeeds without sending anything for an unknown email" do
    result = nil

    expect { result = described_class.call(email: "nobody@example.com") }.not_to have_enqueued_mail
    expect(result).to be_success
  end

  it "sends nothing to an archived user" do
    create(:user, :archived, email: "sam@example.com")

    expect { described_class.call(email: "sam@example.com") }.not_to have_enqueued_mail
  end

  it "sends nothing to an invited user, who must use the invitation link" do
    create(:user, :invited, email: "new@example.com")

    expect { described_class.call(email: "new@example.com") }.not_to have_enqueued_mail
  end
end
