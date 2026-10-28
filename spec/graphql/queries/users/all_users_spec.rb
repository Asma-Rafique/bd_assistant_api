require "rails_helper"

RSpec.describe "allUsers", type: :graphql do
  let(:query) do
    <<~GQL
      query($filters: UserFilterInput) {
        allUsers(filters: $filters) { count currentPage totalPages nextPage prevPage allData { email } }
      }
    GQL
  end
  let(:admin) { create(:user, :super_admin) }

  def all_users(filters: nil, as: admin) = execute_graphql(query, variables: { filters: }, as:)

  it "returns one page of users with its page numbers" do
    create_list(:user, 2)

    page = all_users(filters: { perPage: 2, page: 1 }).dig("data", "allUsers")

    expect(page).to include("count" => 3, "currentPage" => 1, "totalPages" => 2, "nextPage" => 2, "prevPage" => nil)
    expect(page["allData"].size).to eq(2)
  end

  it "applies the filters" do
    create(:user, email: "priya@example.com")

    emails = all_users(filters: { search: "priya" }).dig("data", "allUsers", "allData").pluck("email")

    expect(emails).to eq(["priya@example.com"])
  end

  it "caps the page size" do
    expect(all_users(filters: { perPage: 500 }).dig("data", "allUsers", "totalPages")).to eq(1)
  end

  it "rejects a page number below 1" do
    expect(all_users(filters: { page: 0 })["errors"].first["message"]).to include("must be greater than 0")
  end

  it "is FORBIDDEN for a team member" do
    expect(error_codes(all_users(as: create(:user)))).to eq(["FORBIDDEN"])
  end

  it "requires a signed-in caller" do
    expect(error_codes(all_users(as: nil))).to eq(["UNAUTHENTICATED"])
  end
end
