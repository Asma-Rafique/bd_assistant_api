require "rails_helper"

RSpec.describe User do
  it "stores the email trimmed and in lower case" do
    user = create(:user, email: "  Sam@Example.COM ")

    expect(user.email).to eq("sam@example.com")
  end

  it "rejects a second account with the same email in another letter case" do
    create(:user, email: "sam@example.com")
    user = build(:user, email: "SAM@example.com")

    expect(user).not_to be_valid
    expect(user.errors[:email]).to include("has already been taken")
  end

  it "rejects a weak password with one message per broken rule" do
    user = build(:user, password: "short")

    expect(user).not_to be_valid
    expect(user.errors[:password]).to include(
      "is too short (minimum is 8 characters)", "must include an uppercase letter", "must include a special character"
    )
  end

  it "never stores the plain password" do
    user = create(:user, password: "Passw0rd!")

    expect(user.password_digest).not_to include("Passw0rd!")
    expect(user.authenticate("Passw0rd!")).to eq(user)
  end

  it "cannot sign in once archived" do
    expect(build(:user, :archived)).not_to be_can_sign_in
  end

  describe "#update_password" do
    let(:user) { create(:user) }

    it "signs out every session except the one it keeps" do
      kept = create(:session, user:)
      other = create(:session, user:)

      expect(user.update_password(password: "N3w-passw0rd", password_confirmation: "N3w-passw0rd", keep_session: kept))
        .to be(true)
      expect(user.sessions).to contain_exactly(kept)
      expect(Session.exists?(other.id)).to be(false)
    end

    it "rejects a confirmation that doesn't match" do
      expect(user.update_password(password: "N3w-passw0rd", password_confirmation: "N3w-passw0rd-typo")).to be(false)
      expect(user.errors[:password_confirmation]).to include("doesn't match Password")
    end
  end

  describe "#archive!" do
    it "blocks sign-in and signs out every session" do
      user = create(:user)
      create_list(:session, 2, user:)

      user.archive!

      expect(user).not_to be_can_sign_in
      expect(user.sessions).to be_empty
    end
  end

  describe "#unarchive!" do
    it "lets the user sign in again" do
      user = create(:user, :archived)

      user.unarchive!

      expect(user).to be_can_sign_in
    end
  end
end
