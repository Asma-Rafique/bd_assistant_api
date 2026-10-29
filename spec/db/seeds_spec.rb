require "rails_helper"

RSpec.describe "db/seeds.rb" do
  # Sets the two variables for one run of the seeds, then removes them again.
  def seed(email: "boss@example.com", password: "S3cure!pass")
    ENV["SUPER_ADMIN_EMAIL"] = email
    ENV["SUPER_ADMIN_PASSWORD"] = password
    expect { Rails.application.load_seed }.to output.to_stdout
  ensure
    ENV.delete("SUPER_ADMIN_EMAIL")
    ENV.delete("SUPER_ADMIN_PASSWORD")
  end

  it "creates the first super admin from the environment" do
    seed

    expect(User.find_by(email: "boss@example.com")).to be_super_admin.and(be_can_sign_in)
  end

  it "can run again without creating anything twice" do
    2.times { seed }

    expect(User.where(email: "boss@example.com").count).to eq(1)
  end

  it "skips the super admin when the environment doesn't name one" do
    expect { seed(email: nil, password: nil) }.not_to change(User, :count)
  end

  it "creates no demo accounts outside development" do
    seed

    expect(User.pluck(:email)).to eq(["boss@example.com"])
  end
end
