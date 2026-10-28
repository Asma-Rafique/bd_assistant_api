require "rails_helper"

RSpec.describe Users::FilterQuery do
  def filter(**) = described_class.new(User.all).call(**)

  it "lists newest first" do
    older = create(:user, created_at: 2.days.ago)
    newer = create(:user, created_at: 1.day.ago)

    expect(filter).to eq([newer, older])
  end

  it "filters by role" do
    admin = create(:user, :super_admin)
    create(:user)

    expect(filter(role: "super_admin")).to contain_exactly(admin)
  end

  it "keeps or drops archived users" do
    archived = create(:user, :archived)
    active = create(:user)

    expect(filter(archived: true)).to contain_exactly(archived)
    expect(filter(archived: false)).to contain_exactly(active)
  end

  it "searches email and names, ignoring case" do
    by_name = create(:user, first_name: "Priya")
    by_email = create(:user, email: "priya.k@example.com", first_name: "Kay")
    create(:user, first_name: "Omar")

    expect(filter(search: " PRIYA ")).to contain_exactly(by_name, by_email)
  end

  it "treats % in a search as a plain character" do
    create(:user, first_name: "Omar")

    expect(filter(search: "%")).to be_empty
  end
end
