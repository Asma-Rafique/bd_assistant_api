require "rails_helper"

RSpec.describe UserMailer do
  describe "#verification_code" do
    let(:user) { create(:user, email: "sam@example.com", first_name: "Sam") }

    def mail_for(purpose, encrypted_code: OneTimePassword.encrypt_for_email("042917"))
      described_class.with(user:, encrypted_code:, purpose:).verification_code
    end

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

    it "sends nothing when the code expired before the job ran" do
      encrypted_code = OneTimePassword.encrypt_for_email("042917")

      travel(OneTimePassword::TTL + 1.second) do
        expect { mail_for("login", encrypted_code:).deliver_now }.not_to(change { ActionMailer::Base.deliveries.count })
      end
    end
  end
end
