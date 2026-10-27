require "rails_helper"

RSpec.describe UserPolicy, type: :policy do
  let(:user) { build_stubbed(:user) }
  let(:super_admin) { build_stubbed(:user, :super_admin) }
  let(:record) { build_stubbed(:user) }
  let(:context) { { user: } }

  describe_rule :show? do
    failed "for someone else's account"

    succeed "for their own account" do
      let(:record) { user }
    end

    succeed "for a super admin viewing anyone" do
      let(:user) { super_admin }
    end
  end

  describe "relation scope" do
    let!(:team_member) { create(:user) }
    let!(:admin) { create(:user, :super_admin) }

    def scoped_for(caller) = described_class.new(user: caller).apply_scope(User.all, type: :active_record_relation)

    it "shows a team member only themselves" do
      expect(scoped_for(team_member)).to contain_exactly(team_member)
    end

    it "shows a super admin everyone" do
      expect(scoped_for(admin)).to contain_exactly(team_member, admin)
    end
  end
end
