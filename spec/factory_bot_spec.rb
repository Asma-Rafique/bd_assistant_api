require "rails_helper"

RSpec.describe FactoryBot do
  it "builds a valid record from every factory and trait" do
    expect { described_class.lint(traits: true, strategy: :build) }.not_to raise_error
  end
end
