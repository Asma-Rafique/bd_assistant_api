require "rails_helper"

RSpec.describe Auth::ResetPassword do
  let(:user) { create(:user) }
  let(:token) { user.password_reset_token }

  def reset(token, password: "N3w-passw0rd", password_confirmation: password)
    described_class.call(token:, password:, password_confirmation:)
  end

  it "sets the new password, signs out every device and starts a new session" do
    old_session = create(:session, user:)

    result = reset(token)

    expect(result).to be_success
    expect(user.reload.authenticate("N3w-passw0rd")).to eq(user)
    expect(Session.exists?(old_session.id)).to be(false)
    expect(Session.find_by_token(result.value.token).user).to eq(user)
  end

  it "rejects a token that was already used" do
    reset(token)

    expect(reset(token, password: "An0ther-pass").error.code).to eq(:invalid_token)
  end

  it "rejects an expired token" do
    token

    travel 16.minutes do
      expect(reset(token).error.code).to eq(:invalid_token)
    end
  end

  it "rejects a made-up token" do
    expect(reset("not-a-token").error.code).to eq(:invalid_token)
  end

  it "returns field errors for a weak or mismatched password" do
    result = reset(token, password: "weak", password_confirmation: "other")

    expect(result.error.code).to eq(:validation_failed)
    expect(result.error.field_errors.pluck("field")).to include("password", "passwordConfirmation")
  end
end
