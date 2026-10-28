require "rails_helper"

RSpec.describe "updatePassword", type: :graphql do
  let(:mutation) do
    <<~GQL
      mutation($attributes: UpdatePasswordAttributesInput!) {
        updatePassword(input: { updatePasswordAttributes: $attributes }) { success }
      }
    GQL
  end
  let(:user) { create(:user, password: "Passw0rd!") }

  def update_password(current_password, as: user)
    execute_graphql(mutation, as:, variables: {
                      attributes: { currentPassword: current_password, password: "N3w-passw0rd",
                                    passwordConfirmation: "N3w-passw0rd" }
                    })
  end

  it "changes the signed-in user's password" do
    expect(update_password("Passw0rd!").dig("data", "updatePassword", "success")).to be(true)
    expect(user.reload.authenticate("N3w-passw0rd")).to eq(user)
  end

  it "answers a wrong current password with INVALID_CREDENTIALS" do
    expect(error_codes(update_password("Wrong-pass1"))).to eq(["INVALID_CREDENTIALS"])
  end

  it "requires a signed-in caller" do
    expect(error_codes(update_password("Passw0rd!", as: nil))).to eq(["UNAUTHENTICATED"])
  end
end
