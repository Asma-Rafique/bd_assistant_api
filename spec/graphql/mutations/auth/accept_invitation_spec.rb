require "rails_helper"

RSpec.describe "acceptInvitation", type: :graphql do
  let(:mutation) do
    <<~GQL
      mutation($token: String!, $password: String!) {
        acceptInvitation(input: { acceptInvitationAttributes: {
          token: $token, password: $password, passwordConfirmation: $password
        } }) { token user { email invitationPending } }
      }
    GQL
  end
  let(:user) { create(:user, :invited) }

  def accept(token, password: "N3w-passw0rd")
    execute_graphql(mutation, variables: { token:, password: })
  end

  it "signs the new user in without an Authorization header" do
    data = accept(user.generate_token_for(:invitation)).dig("data", "acceptInvitation")

    expect(data["user"]).to eq({ "email" => user.email, "invitationPending" => false })
    expect(Session.find_by_token(data["token"]).user).to eq(user)
  end

  it "answers INVALID_TOKEN for a bad link" do
    expect(error_codes(accept("not-a-token"))).to eq(["INVALID_TOKEN"])
  end
end
