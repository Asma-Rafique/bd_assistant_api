require "rails_helper"

RSpec.describe Session do
  describe ".find_by_token" do
    let!(:session) { create(:session) }

    it "finds an active session by its plain token" do
      expect(described_class.find_by_token(session.token)).to eq(session)
    end

    it "stores only a digest of the token" do
      expect(session.token_digest).to eq(described_class.digest(session.token))
      expect(session.token_digest).not_to eq(session.token)
    end

    it "ignores an expired session" do
      travel_to((Session::TTL + 1.minute).from_now) do
        expect(described_class.find_by_token(session.token)).to be_nil
      end
    end

    it "ignores a session idle for longer than the idle timeout" do
      travel_to((Session::IDLE_TIMEOUT + 1.minute).from_now) do
        expect(described_class.find_by_token(session.token)).to be_nil
      end
    end

    it "ignores a blank token" do
      expect(described_class.find_by_token("")).to be_nil
    end
  end

  describe "#record_activity!" do
    it "refreshes last_active_at only after the recording interval" do
      session = create(:session)

      expect { session.record_activity! }.not_to(change { session.reload.last_active_at })

      travel(Session::ACTIVITY_RECORD_INTERVAL + 1.second) do
        expect { session.record_activity! }.to(change { session.reload.last_active_at })
      end
    end
  end
end
