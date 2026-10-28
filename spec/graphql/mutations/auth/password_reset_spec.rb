require "rails_helper"

RSpec.describe "Password reset", type: :graphql do
  describe "sendResetPasswordInstructions" do
    let(:mutation) do
      "mutation($email: String!) { sendResetPasswordInstructions(input: { email: $email }) { message } }"
    end

    it "gives the same answer whether or not the account exists" do
      create(:user, email: "sam@example.com")

      known = execute_graphql(mutation, variables: { email: "sam@example.com" })
      unknown = execute_graphql(mutation, variables: { email: "nobody@example.com" })

      expect(known.dig("data", "sendResetPasswordInstructions", "message"))
        .to eq(I18n.t("auth.password_reset_requested"))
      expect(unknown["data"]).to eq(known["data"])
    end
  end

  describe "resetPassword" do
    let(:mutation) do
      <<~GQL
        mutation($attributes: ResetPasswordAttributesInput!) {
          resetPassword(input: { resetPasswordAttributes: $attributes }) { token user { id } }
        }
      GQL
    end
    let(:user) { create(:user) }

    def reset(token)
      execute_graphql(mutation, variables: {
                        attributes: { token:, password: "N3w-passw0rd", passwordConfirmation: "N3w-passw0rd" }
                      })
    end

    it "signs the user in with a new token" do
      result = reset(user.password_reset_token)

      expect(Session.find_by_token(result.dig("data", "resetPassword", "token")).user).to eq(user)
    end

    it "answers a bad token with INVALID_TOKEN" do
      expect(error_codes(reset("not-a-token"))).to eq(["INVALID_TOKEN"])
    end
  end
end
