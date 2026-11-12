require "rails_helper"

RSpec.describe Auth::ResendSignInCode do
  let(:user) { create(:user, email: "sam@example.com") }

  def resend(email: "sam@example.com") = described_class.call(email:, purpose: "login")

  context "with a sign-in in progress" do
    let!(:first_code) { OneTimePassword.issue!(user:, purpose: :login) }

    it "waits for the cooldown before sending again" do
      expect(resend.error.code).to eq(:rate_limited)
    end

    it "emails a new code after the cooldown, and the first one stops working" do
      travel(OneTimePassword::RESEND_COOLDOWN + 1.second) do
        expect { resend }.to have_enqueued_mail(UserMailer, :verification_code)
        expect(user.one_time_passwords.login.sole.correct_code?(first_code)).to be(false)
      end
    end
  end

  it "refuses when no sign-in is in progress, so it can't skip the password" do
    user

    result = nil
    expect { result = resend }.not_to have_enqueued_mail
    expect(result.error).to have_attributes(code: :invalid_code, message: I18n.t("errors.code_not_pending"))
  end
end
