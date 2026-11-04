require "rails_helper"

RSpec.describe Users::UpdateProfile do
  let(:user) { create(:user, first_name: "Sam") }

  it "saves the new fields" do
    result = described_class.call(user:, attributes: { first_name: "Samira" })

    expect(result).to be_success
    expect(user.reload.first_name).to eq("Samira")
  end

  it "answers invalid fields with validation_failed" do
    allow(user).to receive(:update).and_return(false)

    expect(described_class.call(user:, attributes: {}).error.code).to eq(:validation_failed)
  end
end
