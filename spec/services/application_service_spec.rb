require "rails_helper"

RSpec.describe ApplicationService do
  before do
    stub_const("Person", Class.new do
      include ActiveModel::Model

      attr_accessor :first_name

      validates :first_name, presence: true
    end)

    stub_const("Greeter", Class.new(ApplicationService) do
      def initialize(name:)
        @name = name
      end

      def call
        return failure(:validation_failed) if @name == "nobody"

        person = Person.new(first_name: @name)
        return invalid(person) unless person.valid?

        success("Hello, #{@name}")
      end
    end)
  end

  it "passes its arguments through .call and returns a success" do
    result = Greeter.call(name: "Asma")

    expect(result).to be_success
    expect(result.value).to eq("Hello, Asma")
  end

  it "returns a failure with the message from en.yml" do
    result = Greeter.call(name: "nobody")

    expect(result).to be_failure
    expect(result.error.code).to eq(:validation_failed)
    expect(result.error.message).to eq(I18n.t("errors.validation_failed"))
  end

  it "turns an invalid record into field errors" do
    result = Greeter.call(name: "")

    expect(result.error.field_errors).to eq([{ "field" => "firstName", "message" => "can't be blank" }])
  end

  it "raises for a missing keyword instead of guessing" do
    expect { Greeter.call }.to raise_error(ArgumentError, /missing keyword: :name/)
  end
end
