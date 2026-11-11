module Mutations
  module Auth
    class ResendOtp < BaseMutation
      description "Emails a new code for a sign-in in progress. The previous code stops working."

      allow_unauthenticated!
      rate_limit to: 5, within: 15.minutes, by: ->(arguments) { arguments[:email] }
      rate_limit to: 15, within: 15.minutes

      argument :email, String, description: "The email the first code was sent to"
      argument :purpose, Types::Auth::SignInPurposeEnum, description: "Which code to send again"

      field :message, String, null: false, description: "Confirmation message"

      def resolve(email:, purpose:)
        value_or_raise!(::Auth::ResendSignInCode.call(email:, purpose:))
        { message: I18n.t("auth.verification_code_resent") }
      end
    end
  end
end
