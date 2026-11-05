module Mutations
  module Auth
    class ValidateOtp < BaseMutation
      description "Exchanges the 6-digit code emailed by loginUser for a bearer token"

      allow_unauthenticated!
      rate_limit to: 10, within: 15.minutes, by: ->(arguments) { arguments[:email] }
      rate_limit to: 30, within: 15.minutes

      argument :email, String, description: "The email the code was sent to"
      argument :otp_code, String, description: "The 6-digit code from the email"
      argument :purpose, Types::Auth::SignInPurposeEnum, description: "Which code this is"

      field :token, String, null: false, description: "Send as `Authorization: Bearer <token>` on later requests"
      field :user, Types::Users::UserType, null: false, description: "The signed-in user"

      def resolve(email:, otp_code:, purpose:)
        outcome = value_or_raise!(::Auth::VerifySignInCode.call(email:, code: otp_code, purpose:))
        { token: outcome.session.token, user: outcome.user }
      end
    end
  end
end
