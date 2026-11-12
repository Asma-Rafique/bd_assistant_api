require "rails_helper"

RSpec.describe "Password reset", type: :graphql do
  let!(:user) { create(:user, email: "sam@example.com") }

  let(:request_mutation) do
    "mutation($email: String!) { sendResetPasswordInstructions(input: { email: $email }) { message } }"
  end
  let(:validate_mutation) do
    <<~GQL
      mutation($code: String!) {
        validateOtp(input: { email: "sam@example.com", otpCode: $code, purpose: password_reset }) {
          token resetPasswordToken user { id }
        }
      }
    GQL
  end
  let(:set_password_mutation) do
    <<~GQL
      mutation($attributes: ResetPasswordAttributesInput!) {
        setPassword(input: { setPasswordAttributes: $attributes }) { token user { id } }
      }
    GQL
  end

  # Every code issued in these specs is 123456, so the spec knows what the email says.
  before do
    allow(SecureRandom).to receive(:random_number).and_call_original
    allow(SecureRandom).to receive(:random_number).with(10**OneTimePassword::CODE_LENGTH).and_return(123_456)
  end

  def choose_password(token)
    execute_graphql(set_password_mutation, variables: {
                      attributes: { resetPasswordToken: token, password: "N3w-passw0rd",
                                    passwordConfirmation: "N3w-passw0rd" }
                    })
  end

  it "gives the same answer whether or not the account exists" do
    known = execute_graphql(request_mutation, variables: { email: "sam@example.com" })
    unknown = execute_graphql(request_mutation, variables: { email: "nobody@example.com" })

    expect(known.dig("data", "sendResetPasswordInstructions", "message"))
      .to eq(I18n.t("auth.password_reset_requested"))
    expect(unknown["data"]).to eq(known["data"])
  end

  it "resets the password with the emailed code, then signs in" do
    execute_graphql(request_mutation, variables: { email: "sam@example.com" })

    verified = execute_graphql(validate_mutation, variables: { code: "123456" }).dig("data", "validateOtp")
    expect(verified).to include("token" => nil, "user" => { "id" => user.id.to_s })

    signed_in = choose_password(verified["resetPasswordToken"]).dig("data", "setPassword")
    expect(Session.find_by_token(signed_in["token"]).user).to eq(user)
    expect(user.reload.authenticate("N3w-passw0rd")).to eq(user)
  end

  it "rejects a code that isn't 6 digits before looking it up" do
    result = execute_graphql(validate_mutation, variables: { code: "12345" })

    expect(result["errors"].first["message"]).to include("otpCode is invalid")
  end

  it "answers a bad token with INVALID_TOKEN" do
    expect(error_codes(choose_password("not-a-token"))).to eq(["INVALID_TOKEN"])
  end
end
