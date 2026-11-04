require "rails_helper"

RSpec.describe RateLimiter do
  def limiter(discriminator = "sam@example.com", limit: 2)
    described_class.new(scope: "test", discriminator:, limit:, period: 15.minutes)
  end

  it "allows attempts up to the limit, then refuses" do
    expect(Array.new(3) { limiter.exceeded? }).to eq([false, false, true])
  end

  it "counts each discriminator separately" do
    2.times { limiter.exceeded? }

    expect(limiter("ben@example.com")).not_to be_exceeded
  end

  it "counts an email the same whatever its letter case or spacing" do
    limiter("sam@example.com").exceeded?
    limiter(" SAM@example.com").exceeded?

    expect(limiter("Sam@Example.com ")).to be_exceeded
  end

  it "starts a fresh count once the window has passed" do
    3.times { limiter.exceeded? }

    travel 16.minutes do
      expect(limiter).not_to be_exceeded
    end
  end
end
