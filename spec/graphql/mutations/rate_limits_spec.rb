require "rails_helper"

RSpec.describe "Rate limits", type: :graphql do
  let(:login_mutation) do
    <<~GQL
      mutation($email: String!, $password: String!) {
        loginUser(input: { loginAttributes: { email: $email, password: $password } }) { token }
      }
    GQL
  end

  def login(email, password = "Wrong-pass1", ip: "127.0.0.1")
    BdAssistantApiSchema.execute(login_mutation, variables: { email:, password: },
                                                 context: { ip_address: ip }).to_h
  end

  it "stops password guessing on one account after 10 tries, even with the right password" do
    user = create(:user)
    10.times { login(user.email) }

    expect(error_codes(login(user.email, "Passw0rd!"))).to eq(["RATE_LIMITED"])
  end

  it "counts the email whatever its letter case" do
    10.times { |n| login(n.even? ? "sam@example.com" : "SAM@example.com") }

    expect(error_codes(login("Sam@Example.com"))).to eq(["RATE_LIMITED"])
  end

  it "limits one IP to 30 tries across many emails, even aliased into one request" do
    aliased = Array.new(31) do |n|
      %(login#{n}: loginUser(input: { loginAttributes: { email: "guess#{n}@example.com", password: "x" } }) { token })
    end

    result = BdAssistantApiSchema.execute("mutation { #{aliased.join(" ")} }", context: { ip_address: "10.0.0.1" }).to_h

    expect(error_codes(result).count("RATE_LIMITED")).to eq(1)
    expect(error_codes(login("someone@example.com", ip: "10.0.0.2"))).to eq(["INVALID_CREDENTIALS"])
  end

  it "limits password changes per signed-in user" do
    user = create(:user)
    change = <<~GQL
      mutation {
        updatePassword(input: { updatePasswordAttributes: {
          currentPassword: "Wrong-pass1", password: "N3w-passw0rd", passwordConfirmation: "N3w-passw0rd"
        } }) { success }
      }
    GQL
    5.times { execute_graphql(change, as: user) }

    expect(error_codes(execute_graphql(change, as: user))).to eq(["RATE_LIMITED"])
  end

  it "declares a limit on every mutation that works signed out" do
    open_mutations = BdAssistantApiSchema.mutation.fields.values.map(&:mutation).reject(&:authentication_required)

    expect(open_mutations).to all(satisfy("declare a rate limit") { it.rate_limit_rules.any? })
  end
end
