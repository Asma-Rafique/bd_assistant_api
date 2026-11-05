module Mutations
  module Auth
    class LoginUser < BaseMutation
      description <<~DESC.squish
        Checks email and password. With OTP on, emails a 6-digit code to confirm with validateOtp
        and returns no token; with it off, signs in at once.
      DESC

      allow_unauthenticated!
      rate_limit to: 10, within: 15.minutes, by: ->(arguments) { arguments[:login_attributes][:email] }
      rate_limit to: 30, within: 15.minutes

      argument :login_attributes, Types::Auth::LoginAttributesInput, description: "Email and password"

      field :message, String, null: false, description: "Says whether you're signed in or a code was emailed"
      field :token, String, description: "Send as `Authorization: Bearer <token>`. Null when a code was emailed"
      field :user, Types::Users::UserType, description: "The signed-in user. Null when a code was emailed"

      def resolve(login_attributes:)
        outcome = value_or_raise!(::Auth::Login.call(**login_attributes.to_h))
        return { message: I18n.t("auth.verification_code_sent"), token: nil, user: nil } unless outcome.session

        { message: I18n.t("auth.signed_in"), token: outcome.session.token, user: outcome.user }
      end
    end
  end
end
