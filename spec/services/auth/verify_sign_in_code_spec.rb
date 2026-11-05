require "rails_helper"

RSpec.describe Auth::VerifySignInCode do
  let(:user) { create(:user, email: "sam@example.com") }
  let!(:code) { OneTimePassword.issue!(user:, purpose: :login) }
  let(:wrong_code) { code.tr("0-9", "1-90") }

  def verify(entered, email: "sam@example.com") = described_class.call(email:, code: entered, purpose: "login")

  it "starts a session for the right code" do
    result = verify(code)

    expect(result.value.user).to eq(user)
    expect(Session.find_by_token(result.value.session.token)).to eq(result.value.session)
  end

  it "records the sign-in" do
    expect { verify(code) }.to(change { user.reload.last_sign_in_at })
  end

  it "accepts the email in any letter case" do
    expect(verify(code, email: "SAM@example.com")).to be_success
  end

  it "works only once" do
    verify(code)

    expect(verify(code).error.code).to eq(:invalid_code)
  end

  it "rejects a wrong code without starting a session" do
    result = verify(wrong_code)

    expect(result.error).to have_attributes(code: :invalid_code, message: I18n.t("errors.invalid_code"))
    expect(Session.count).to eq(0)
  end

  it "says so once the code is locked, even for the right code" do
    OneTimePassword::MAX_FAILED_ATTEMPTS.times { verify(wrong_code) }

    expect(verify(code).error.message).to eq(I18n.t("errors.code_locked"))
  end

  it "rejects an expired code" do
    travel_to((OneTimePassword::TTL + 1.second).from_now) do
      expect(verify(code).error.code).to eq(:invalid_code)
    end
  end

  it "rejects a code for an email with no sign-in in progress" do
    expect(verify(code, email: "nobody@example.com").error.code).to eq(:invalid_code)
  end

  it "refuses a user archived after the code was sent" do
    user.archive!

    expect(verify(code).error.code).to eq(:sign_in_blocked)
  end
end
