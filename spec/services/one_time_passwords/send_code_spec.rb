require "rails_helper"

RSpec.describe OneTimePasswords::SendCode do
  let(:user) { create(:user) }

  it "stores a new code for the user and purpose" do
    described_class.call(user:, purpose: :login)

    expect(user.one_time_passwords.login).to exist
  end

  it "emails the code it issued" do
    allow(OneTimePassword).to receive(:issue!).with(user:, purpose: "login").and_return("123456")

    expect { described_class.call(user:, purpose: :login) }
      .to have_enqueued_mail(UserMailer, :verification_code)
      .with(params: { user:, code: "123456", purpose: "login" }, args: [])
  end

  it "succeeds" do
    expect(described_class.call(user:, purpose: :password_reset)).to be_success
  end
end
