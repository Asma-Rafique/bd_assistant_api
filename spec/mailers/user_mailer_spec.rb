require "rails_helper"

RSpec.describe UserMailer do
  describe "#verification_code" do
    let(:user) { create(:user, email: "sam@example.com", first_name: "Sam") }

    def mail_for(purpose) = described_class.with(user:, code: "042917", purpose:).verification_code

    it "sends a login code to the user" do
      mail = mail_for("login")

      expect(mail.to).to eq(["sam@example.com"])
      expect(mail.subject).to eq("Your BD Assistant sign-in code")
      expect(mail.text_part.body.to_s).to include("042917", "finish signing in", "10 minutes")
      expect(mail.html_part.body.to_s).to include("042917")
    end

    it "words a password reset code differently" do
      mail = mail_for("password_reset")

      expect(mail.subject).to eq("Your BD Assistant password reset code")
      expect(mail.text_part.body.to_s).to include("042917", "reset your password")
    end
  end
end
