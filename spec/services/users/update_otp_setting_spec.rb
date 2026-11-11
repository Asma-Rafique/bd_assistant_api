require "rails_helper"

RSpec.describe Users::UpdateOtpSetting do
  let(:user) { create(:user, password: "Passw0rd!") }

  def update(enabled:, current_password: "Passw0rd!") = described_class.call(user:, enabled:, current_password:)

  it "is off for a new user" do
    expect(user.otp_enabled).to be(false)
  end

  it "switches the sign-in code on, then off again" do
    expect(update(enabled: true)).to be_success
    expect(user.reload.otp_enabled).to be(true)

    update(enabled: false)
    expect(user.reload.otp_enabled).to be(false)
  end

  it "ends a sign-in waiting for a code when switched off, but keeps a password reset code" do
    update(enabled: true)
    OneTimePassword.issue!(user:, purpose: :login)
    OneTimePassword.issue!(user:, purpose: :password_reset)

    update(enabled: false)

    expect(user.one_time_passwords.pluck(:purpose)).to eq(["password_reset"])
  end

  it "refuses a wrong current password and changes nothing" do
    result = update(enabled: true, current_password: "Wrong-pass1")

    expect(result.error.code).to eq(:invalid_credentials)
    expect(result.error.message).to eq(I18n.t("errors.current_password_invalid"))
    expect(user.reload.otp_enabled).to be(false)
  end
end
