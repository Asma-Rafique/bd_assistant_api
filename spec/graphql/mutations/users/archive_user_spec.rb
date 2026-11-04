require "rails_helper"

RSpec.describe "archiveUser", type: :graphql do
  let(:mutation) do
    <<~GQL
      mutation($id: ID!, $archived: Boolean!) {
        archiveUser(input: { id: $id, archived: $archived }) { user { archivedAt } }
      }
    GQL
  end
  let(:admin) { create(:user, :super_admin) }
  let(:target) { create(:user) }

  def archive_user(user, archived: true, as: admin)
    execute_graphql(mutation, variables: { id: user.id.to_s, archived: }, as:)
  end

  it "archives a user and signs them out" do
    create(:session, user: target)

    expect(archive_user(target).dig("data", "archiveUser", "user", "archivedAt")).to be_present
    expect(target.reload).not_to be_can_sign_in
    expect(target.sessions).to be_empty
  end

  it "restores an archived user" do
    target.archive!

    expect(archive_user(target, archived: false).dig("data", "archiveUser", "user", "archivedAt")).to be_nil
  end

  it "stops an admin archiving themselves" do
    expect(error_codes(archive_user(admin))).to eq(["FORBIDDEN"])
    expect(admin.reload).to be_can_sign_in
  end

  it "hides other users from a team member as NOT_FOUND" do
    expect(error_codes(archive_user(target, as: create(:user)))).to eq(["NOT_FOUND"])
  end

  it "is FORBIDDEN for a team member archiving themselves" do
    team_member = create(:user)

    expect(error_codes(archive_user(team_member, as: team_member))).to eq(["FORBIDDEN"])
  end
end
