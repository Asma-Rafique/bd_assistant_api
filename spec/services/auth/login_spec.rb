require "rails_helper"

RSpec.describe Auth::Login do
  let!(:user) { create(:user, email: "sam@example.com", password: "Passw0rd!") }

  it "starts a session for the right email and password" do
    result = described_class.call(email: "sam@example.com", password: "Passw0rd!")

    expect(result).to be_success
    expect(result.value.user).to eq(user)
    expect(Session.find_by_token(result.value.token)).to eq(result.value)
  end

  it "accepts the email in any letter case" do
    expect(described_class.call(email: "SAM@example.com", password: "Passw0rd!")).to be_success
  end

  it "records when the user signed in" do
    expect { described_class.call(email: "sam@example.com", password: "Passw0rd!") }
      .to(change { user.reload.last_sign_in_at })
  end

  it "rejects a wrong password" do
    result = described_class.call(email: "sam@example.com", password: "Wrong-pass1")

    expect(result.error.code).to eq(:invalid_credentials)
  end

  it "gives an unknown email the same answer as a wrong password" do
    unknown = described_class.call(email: "nobody@example.com", password: "Passw0rd!")
    wrong = described_class.call(email: "sam@example.com", password: "Wrong-pass1")

    expect(unknown.error).to eq(wrong.error)
  end

  it "refuses an archived user without starting a session" do
    user.update!(archived_at: Time.current)

    result = described_class.call(email: "sam@example.com", password: "Passw0rd!")

    expect(result.error.code).to eq(:sign_in_blocked)
    expect(Session.count).to eq(0)
  end

  it "treats an invited user, who has no password yet, as wrong credentials" do
    create(:user, :invited, email: "new@example.com")

    result = described_class.call(email: "new@example.com", password: "")

    expect(result.error.code).to eq(:invalid_credentials)
  end
end
