require "rails_helper"

RSpec.describe BdAssistantApiSchema do
  it "matches the committed schema.graphql (run bin/rails graphql:schema:idl after changing the API)" do
    expect(described_class.to_definition).to eq(Rails.root.join("schema.graphql").read)
  end

  describe "error handling" do
    # A copy of the schema with two fields that fail on purpose. It inherits
    # the real schema's rescue_from handlers, which is what's being tested.
    let(:schema) do
      query_type = Class.new(Types::BaseObject) do
        graphql_name "FailingQuery"

        field :invalid_record, String, null: false, description: "Saves a user with a bad email"
        field :crash, String, null: false, description: "Raises an unexpected error"

        def invalid_record = User.create!(email: "not-an-email", password: "Passw0rd!")
        def crash = raise("database password is hunter2")
      end
      Class.new(described_class) { query(query_type) }
    end

    def run(field) = schema.execute("{ #{field} }").to_h

    it "turns a failed save! into VALIDATION_FAILED with field errors" do
      error = run("invalidRecord")["errors"].first

      expect(error.dig("extensions", "code")).to eq("VALIDATION_FAILED")
      expect(error.dig("extensions", "fieldErrors").pluck("field")).to eq(["email"])
    end

    it "raises unexpected errors in development and test, so you see them" do
      expect { run("crash") }.to raise_error(RuntimeError, /hunter2/)
    end

    it "hides unexpected errors in production and reports them instead" do
      allow(Rails.env).to receive(:local?).and_return(false)
      allow(Rails.error).to receive(:report)

      error = run("crash")["errors"].first

      expect(error["message"]).to eq(I18n.t("errors.internal"))
      expect(error.to_s).not_to include("hunter2")
      expect(Rails.error).to have_received(:report).with(instance_of(RuntimeError), handled: true)
    end
  end
end
