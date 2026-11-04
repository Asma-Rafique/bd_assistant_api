require "rails_helper"

RSpec.describe "validateInvitationToken", type: :graphql do
  def validate(token)
    execute_graphql(<<~GQL, variables: { token: }).dig("data", "validateInvitationToken")
      query($token: String!) { validateInvitationToken(token: $token) { valid error } }
    GQL
  end

  it "says a fresh link is valid" do
    token = create(:user, :invited).generate_token_for(:invitation)

    expect(validate(token)).to eq({ "valid" => true, "error" => nil })
  end

  it "says why a bad link can't be used" do
    expect(validate("not-a-token")).to eq({ "valid" => false, "error" => I18n.t("errors.invalid_token") })
  end
end
