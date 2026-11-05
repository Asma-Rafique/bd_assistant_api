require "rails_helper"

RSpec.describe OneTimePassword do
  let(:user) { create(:user) }

  def login_code_record = user.one_time_passwords.login.sole

  describe ".issue!" do
    it "returns a 6-digit code and stores only its digest" do
      code = described_class.issue!(user:, purpose: :login)

      expect(code).to match(/\A\d{6}\z/)
      expect(login_code_record.code_digest).to eq(described_class.digest(code))
      expect(login_code_record.code_digest).not_to include(code)
    end

    it "replaces the earlier code for the same purpose, so the old one stops working" do
      old_code = described_class.issue!(user:, purpose: :login)
      described_class.issue!(user:, purpose: :login)

      expect(user.one_time_passwords.login.count).to eq(1)
      expect(login_code_record.correct_code?(old_code)).to be(false)
    end

    it "resets the failed attempts and expiry of the code it replaces" do
      described_class.issue!(user:, purpose: :login)
      login_code_record.update!(failed_attempts: OneTimePassword::MAX_FAILED_ATTEMPTS, expires_at: 1.minute.ago)

      code = described_class.issue!(user:, purpose: :login)

      expect(login_code_record.reload.correct_code?(code)).to be(true)
    end

    it "keeps a separate code for each purpose" do
      described_class.issue!(user:, purpose: :login)
      described_class.issue!(user:, purpose: :password_reset)

      expect(user.one_time_passwords.pluck(:purpose)).to contain_exactly("login", "password_reset")
    end
  end

  describe ".pending_for" do
    before { described_class.issue!(user:, purpose: :login) }

    it "finds the code by email, in any letter case" do
      expect(described_class.pending_for(user.email.upcase, purpose: :login)).to eq(login_code_record)
    end

    it "ignores a code issued for another purpose" do
      expect(described_class.pending_for(user.email, purpose: :password_reset)).to be_nil
    end
  end

  describe "#correct_code?" do
    let!(:code) { described_class.issue!(user:, purpose: :login) }
    # Every digit shifted by one, so it's always different from the real code.
    let(:wrong_code) { code.tr("0-9", "1-90") }

    it "accepts the right code" do
      expect(login_code_record.correct_code?(code)).to be(true)
    end

    it "counts each wrong guess" do
      expect { login_code_record.correct_code?(wrong_code) }
        .to change { login_code_record.reload.failed_attempts }.by(1)
    end

    it "locks after too many wrong guesses, even for the right code" do
      record = login_code_record
      OneTimePassword::MAX_FAILED_ATTEMPTS.times { record.correct_code?(wrong_code) }

      expect(record).to be_locked
      expect(record.correct_code?(code)).to be(false)
    end

    it "rejects the right code once it has expired" do
      travel_to((OneTimePassword::TTL + 1.second).from_now) do
        expect(login_code_record.correct_code?(code)).to be(false)
      end
    end
  end

  describe "#resendable?" do
    before { described_class.issue!(user:, purpose: :login) }

    it "waits for the cooldown after a code is sent" do
      expect(login_code_record).not_to be_resendable

      travel(OneTimePassword::RESEND_COOLDOWN + 1.second) do
        expect(login_code_record).to be_resendable
      end
    end
  end

  it "is deleted with its user" do
    described_class.issue!(user:, purpose: :login)

    expect { user.destroy! }.to change(described_class, :count).by(-1)
  end
end
