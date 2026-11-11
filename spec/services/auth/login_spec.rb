require "rails_helper"

RSpec.describe Auth::Login do
  let!(:user) { create(:user, email: "sam@example.com", password: "Passw0rd!") }

  def login(email: "sam@example.com", password: "Passw0rd!") = described_class.call(email:, password:)

  context "with the sign-in code off" do
    it "starts a session for the right email and password" do
      result = login

      expect(result).to be_success
      expect(result.value.user).to eq(user)
      expect(Session.find_by_token(result.value.session.token)).to eq(result.value.session)
    end

    it "accepts the email in any letter case" do
      expect(login(email: "SAM@example.com")).to be_success
    end

    it "records when the user signed in" do
      expect { login }.to(change { user.reload.last_sign_in_at })
    end

    it "sends no code" do
      expect { login }.not_to have_enqueued_mail
    end
  end

  context "with the sign-in code on" do
    before { user.update!(otp_enabled: true) }

    it "emails a login code instead of starting a session" do
      result = nil

      expect { result = login }.to have_enqueued_mail(UserMailer, :verification_code)
      expect(result.value.session).to be_nil
      expect(Session.count).to eq(0)
      expect(user.one_time_passwords.login).to exist
    end

    it "doesn't count it as a sign-in until the code is confirmed" do
      expect { login }.not_to(change { user.reload.last_sign_in_at })
    end

    it "sends no code for a wrong password" do
      expect { login(password: "Wrong-pass1") }.not_to have_enqueued_mail
    end
  end

  it "rejects a wrong password" do
    expect(login(password: "Wrong-pass1").error.code).to eq(:invalid_credentials)
  end

  it "gives an unknown email the same answer as a wrong password" do
    expect(login(email: "nobody@example.com").error).to eq(login(password: "Wrong-pass1").error)
  end

  it "refuses an archived user without starting a session" do
    user.update!(archived_at: Time.current)

    result = login

    expect(result.error.code).to eq(:sign_in_blocked)
    expect(Session.count).to eq(0)
  end

  it "treats an invited user, who has no password yet, as wrong credentials" do
    create(:user, :invited, email: "new@example.com")

    expect(login(email: "new@example.com", password: "").error.code).to eq(:invalid_credentials)
  end
end
