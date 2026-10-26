require "rails_helper"

RSpec.describe ServiceResult do
  let(:error) { ServiceError.new(code: :validation_failed, message: "Name can't be blank") }

  describe ".success" do
    it "holds the value and no error" do
      result = described_class.success(42)

      expect(result).to be_success
      expect(result.value).to eq(42)
      expect(result.error).to be_nil
    end
  end

  describe ".failure" do
    it "holds the error and no value" do
      result = described_class.failure(error)

      expect(result).to be_failure
      expect(result.error).to eq(error)
      expect(result.value).to be_nil
    end
  end

  it "cannot be changed after it is built" do
    expect(described_class.success(42)).to be_frozen
  end
end
