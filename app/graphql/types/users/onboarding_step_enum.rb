module Types
  module Users
    class OnboardingStepEnum < Types::BaseEnum
      DESCRIPTIONS = {
        "step1" => "Step 1: first and last name"
      }.freeze

      description "An onboarding step, in the order users complete them"

      User::ONBOARDING_STEPS.each_key { value it.to_s, DESCRIPTIONS.fetch(it.to_s), value: it }
    end
  end
end
