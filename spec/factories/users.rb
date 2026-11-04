FactoryBot.define do
  factory :user do
    sequence(:email) { "user#{it}@example.com" }
    password { "Passw0rd!" }
    first_name { "Sam" }
    last_name { "Lee" }
    role { :team_member }

    trait :super_admin do
      role { :super_admin }
    end

    trait :archived do
      archived_at { 1.day.ago }
    end

    # Invited but not accepted yet, so no password.
    trait :invited do
      password { nil }
      invitation_sent_at { Time.current }
      invited_by factory: %i[user super_admin]
    end
  end
end
