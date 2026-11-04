require "rails_helper"

RSpec.describe Auth::AcceptInvitation do
  let(:user) { create(:user, :invited) }
  let(:token) { user.generate_token_for(:invitation) }

  def accept(token, password: "N3w-passw0rd", password_confirmation: password)
    described_class.call(token:, password:, password_confirmation:)
  end

  it "sets the password and starts a session" do
    result = accept(token)

    expect(result).to be_success
    expect(user.reload.authenticate("N3w-passw0rd")).to eq(user)
    expect(Session.find_by_token(result.value.token).user).to eq(user)
  end

  it "rejects a link that was already used" do
    accept(token)

    expect(accept(token).error.code).to eq(:invalid_token)
  end

  it "rejects the link of an archived user" do
    user.archive!

    expect(accept(token).error.code).to eq(:invalid_token)
  end

  it "returns field errors for a weak password and keeps the invitation open" do
    result = accept(token, password: "weak")

    expect(result.error.field_errors.pluck("field")).to include("password")
    expect(user.reload).to be_invitation_pending
  end
end
