require "rails_helper"

RSpec.describe User::Onboarding do
  let(:user) { create(:user, :invited, first_name: nil, last_name: nil) }

  it "starts a new invitee on step 1, listing the empty fields" do
    onboarding = user.onboarding

    expect(onboarding).to be_required
    expect(onboarding.current_step).to have_attributes(name: :step1, position: 1,
                                                       missing_fields: %i[first_name last_name])
    expect(onboarding).not_to be_completed
  end

  it "is completed once the first and last name are filled in" do
    user.update!(first_name: "Sam", last_name: "Lee")

    expect(user.onboarding).to be_completed
    expect(user.onboarding.current_step).to be_nil
  end

  it "keeps a step open while one of its fields is missing" do
    user.update!(first_name: "Sam")

    expect(user.onboarding.current_step.missing_fields).to eq(%i[last_name])
  end

  it "doesn't count a name that's only spaces" do
    user.update!(first_name: "  ", last_name: "Lee")

    expect(user.onboarding).not_to be_completed
  end

  it "isn't required of a super admin, even with no name" do
    admin = create(:user, :super_admin, first_name: nil, last_name: nil)

    expect(admin.onboarding).not_to be_required
    expect(admin.onboarding).to be_completed
    expect(admin.onboarding.steps.first).not_to be_completed
  end
end
