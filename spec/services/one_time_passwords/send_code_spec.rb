require "rails_helper"

RSpec.describe OneTimePasswords::SendCode do
  let(:user) { create(:user) }

  def login_code_record = user.one_time_passwords.login.sole

  it "stores a new code for the user and purpose" do
    described_class.call(user:, purpose: :login)

    expect(user.one_time_passwords.login).to exist
  end

  it "emails the code it issued, encrypted so the queued job never holds it in plain text" do
    allow(OneTimePassword).to receive(:issue!).with(user:, purpose: "login").and_return("123456")

    expect { described_class.call(user:, purpose: :login) }.to have_enqueued_mail(UserMailer, :verification_code)

    job_args = ActiveJob::Base.queue_adapter.enqueued_jobs.sole[:args]
    params = ActiveJob::Arguments.deserialize(job_args).last[:params]
    expect(job_args.to_json).not_to include("123456")
    expect(OneTimePassword.decrypt_for_email(params[:encrypted_code])).to eq("123456")
  end

  it "succeeds" do
    expect(described_class.call(user:, purpose: :password_reset)).to be_success
  end

  context "when a code was sent moments ago" do
    before { described_class.call(user:, purpose: :login) }

    it "sends nothing and keeps the code already emailed" do
      digest = login_code_record.code_digest

      expect { described_class.call(user:, purpose: :login) }.not_to have_enqueued_mail(UserMailer, :verification_code)
      expect(login_code_record.code_digest).to eq(digest)
    end

    it "fails with the cooldown message" do
      result = described_class.call(user:, purpose: :login)

      expect(result.error).to have_attributes(code: :rate_limited, message: I18n.t("errors.resend_cooldown"))
    end

    it "still sends a code for the other purpose" do
      expect { described_class.call(user:, purpose: :password_reset) }
        .to have_enqueued_mail(UserMailer, :verification_code)
    end

    it "replaces a locked code at once" do
      login_code_record.update!(failed_attempts: OneTimePassword::MAX_FAILED_ATTEMPTS)

      expect(described_class.call(user:, purpose: :login)).to be_success
    end
  end

  it "sends a new code once the cooldown has passed" do
    described_class.call(user:, purpose: :login)

    travel(OneTimePassword::RESEND_COOLDOWN + 1.second) do
      expect { described_class.call(user:, purpose: :login) }.to have_enqueued_mail(UserMailer, :verification_code)
    end
  end
end
