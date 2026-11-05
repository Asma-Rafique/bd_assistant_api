require "rails_helper"

RSpec.describe UserMailer do
  describe "#password_reset" do
    let(:user) { create(:user, email: "sam@example.com", first_name: "Sam") }
    let(:mail) { described_class.with(user:).password_reset }

    it "goes to the user with a clear subject" do
      expect(mail.to).to eq(["sam@example.com"])
      expect(mail.subject).to eq("Reset your BD Assistant password")
    end

    it "links to the frontend with a token that finds the user" do
      token = mail.text_part.body.to_s[%r{/reset-password\?token=(\S+)}, 1]

      expect(mail.text_part.body.to_s).to include("#{Rails.configuration.x.frontend_url}/reset-password?token=")
      expect(User.find_by_password_reset_token(CGI.unescape(token))).to eq(user)
    end
  end

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
