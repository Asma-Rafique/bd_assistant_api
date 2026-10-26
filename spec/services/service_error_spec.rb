require "rails_helper"

RSpec.describe ServiceError do
  it "accepts a code from CODES" do
    error = described_class.new(code: :validation_failed, message: "Check the fields")

    expect(error.code).to eq(:validation_failed)
    expect(error.field_errors).to eq([])
  end

  it "rejects a code that is not in CODES" do
    expect { described_class.new(code: :not_a_code, message: "x") }
      .to raise_error(ArgumentError, /Unknown service error code: not_a_code/)
  end

  describe ".from_record" do
    before do
      stub_const("Person", Class.new do
        include ActiveModel::Model

        attr_accessor :first_name

        validates :first_name, presence: true
      end)
    end

    it "turns a record's validation errors into a validation_failed error" do
      person = Person.new(first_name: "")
      person.validate

      error = described_class.from_record(person)

      expect(error.code).to eq(:validation_failed)
      expect(error.message).to eq("First name can't be blank")
      expect(error.field_errors).to eq([{ "field" => "firstName", "message" => "can't be blank" }])
    end
  end
end
