require "rails_helper"

RSpec.describe "Signing in with an emailed code", type: :graphql do
  let!(:user) { create(:user, :otp_enabled, email: "sam@example.com") }

  let(:login_mutation) do
    <<~GQL
      mutation {
        loginUser(input: { loginAttributes: { email: "sam@example.com", password: "Passw0rd!" } }) {
          message token user { id }
        }
      }
    GQL
  end

  let(:validate_mutation) do
    <<~GQL
      mutation($code: String!) {
        validateOtp(input: { email: "sam@example.com", otpCode: $code, purpose: login }) {
          token user { id email }
        }
      }
    GQL
  end

  let(:resend_mutation) do
    'mutation { resendOtp(input: { email: "sam@example.com", purpose: login }) { message } }'
  end

  # Every code issued in these specs is 123456, so the spec knows what the email says.
  # Other random numbers, such as the session token's, stay random.
  before do
    allow(SecureRandom).to receive(:random_number).and_call_original
    allow(SecureRandom).to receive(:random_number).with(10**OneTimePassword::CODE_LENGTH).and_return(123_456)
  end

  it "returns no token from loginUser, only a message" do
    payload = execute_graphql(login_mutation).dig("data", "loginUser")

    expect(payload).to eq("message" => I18n.t("auth.verification_code_sent"), "token" => nil, "user" => nil)
  end

  it "signs in with the emailed code" do
    execute_graphql(login_mutation)

    payload = execute_graphql(validate_mutation, variables: { code: "123456" }).dig("data", "validateOtp")

    expect(payload["user"]).to include("id" => user.id.to_s, "email" => "sam@example.com")
    expect(Session.find_by_token(payload["token"]).user).to eq(user)
  end

  it "answers a wrong code with INVALID_CODE" do
    execute_graphql(login_mutation)

    expect(error_codes(execute_graphql(validate_mutation, variables: { code: "000000" }))).to eq(["INVALID_CODE"])
  end

  it "resends the code after the cooldown" do
    execute_graphql(login_mutation)

    travel(OneTimePassword::RESEND_COOLDOWN + 1.second) do
      expect(execute_graphql(resend_mutation).dig("data", "resendOtp", "message"))
        .to eq(I18n.t("auth.verification_code_resent"))
    end
  end

  it "answers a resend inside the cooldown with RATE_LIMITED" do
    execute_graphql(login_mutation)

    expect(error_codes(execute_graphql(resend_mutation))).to eq(["RATE_LIMITED"])
  end
end
