require "rails_helper"

RSpec.describe "updateOtpSetting", type: :graphql do
  let(:mutation) do
    <<~GQL
      mutation($enabled: Boolean!, $currentPassword: String!) {
        updateOtpSetting(input: { enabled: $enabled, currentPassword: $currentPassword }) {
          user { otpEnabled }
        }
      }
    GQL
  end
  let(:user) { create(:user, password: "Passw0rd!") }

  def update_otp_setting(current_password, as: user)
    execute_graphql(mutation, as:, variables: { enabled: true, currentPassword: current_password })
  end

  it "switches the sign-in code on for the signed-in user" do
    expect(update_otp_setting("Passw0rd!").dig("data", "updateOtpSetting", "user", "otpEnabled")).to be(true)
    expect(user.reload.otp_enabled).to be(true)
  end

  it "answers a wrong current password with INVALID_CREDENTIALS" do
    expect(error_codes(update_otp_setting("Wrong-pass1"))).to eq(["INVALID_CREDENTIALS"])
  end

  it "requires a signed-in caller" do
    expect(error_codes(update_otp_setting("Passw0rd!", as: nil))).to eq(["UNAUTHENTICATED"])
  end
end
