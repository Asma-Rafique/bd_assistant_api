require "rails_helper"

RSpec.describe "loginUser and logout", type: :graphql do
  let(:login_mutation) do
    <<~GQL
      mutation($email: String!, $password: String!) {
        loginUser(input: { loginAttributes: { email: $email, password: $password } }) {
          token
          user { id email role }
        }
      }
    GQL
  end

  describe "loginUser" do
    let!(:user) { create(:user, email: "sam@example.com") }

    it "returns a working token and the user" do
      result = execute_graphql(login_mutation, variables: { email: "sam@example.com", password: "Passw0rd!" })

      payload = result.dig("data", "loginUser")
      expect(payload["user"]).to include("id" => user.id.to_s, "role" => "team_member")
      expect(Session.find_by_token(payload["token"]).user).to eq(user)
    end

    it "answers a wrong password with INVALID_CREDENTIALS" do
      result = execute_graphql(login_mutation, variables: { email: "sam@example.com", password: "Wrong-pass1" })

      expect(error_codes(result)).to eq(["INVALID_CREDENTIALS"])
    end
  end

  describe "logout" do
    let(:logout_mutation) { "mutation { logout(input: {}) { message } }" }

    it "ends the current session" do
      session = create(:session)

      result = execute_graphql(logout_mutation, session:)

      expect(result.dig("data", "logout", "message")).to eq(I18n.t("auth.logged_out"))
      expect(Session.exists?(session.id)).to be(false)
    end

    it "requires a signed-in caller" do
      expect(error_codes(execute_graphql(logout_mutation))).to eq(["UNAUTHENTICATED"])
    end
  end
end
