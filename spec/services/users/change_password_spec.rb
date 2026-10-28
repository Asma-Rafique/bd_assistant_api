require "rails_helper"

RSpec.describe Users::ChangePassword do
  let(:user) { create(:user, password: "Passw0rd!") }
  let(:current_session) { create(:session, user:) }

  def change(current_password: "Passw0rd!", password: "N3w-passw0rd", password_confirmation: password)
    described_class.call(user:, current_password:, password:, password_confirmation:, current_session:)
  end

  it "changes the password, keeps this device and signs out the others" do
    other_session = create(:session, user:)

    expect(change).to be_success
    expect(user.reload.authenticate("N3w-passw0rd")).to eq(user)
    expect(Session.exists?(current_session.id)).to be(true)
    expect(Session.exists?(other_session.id)).to be(false)
  end

  it "refuses a wrong current password and changes nothing" do
    result = change(current_password: "Wrong-pass1")

    expect(result.error.code).to eq(:invalid_credentials)
    expect(result.error.message).to eq(I18n.t("errors.current_password_invalid"))
    expect(user.reload.authenticate("Passw0rd!")).to eq(user)
  end

  it "keeps every session when the new password is invalid" do
    other_session = create(:session, user:)

    expect(change(password: "weak").error.code).to eq(:validation_failed)
    expect(Session.exists?(other_session.id)).to be(true)
  end
end
