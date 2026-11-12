module Mutations
  module Auth
    class SetPassword < BaseMutation
      description "Sets a new password with the token from validateOtp, signs out every device and signs in"

      allow_unauthenticated!
      rate_limit to: 10, within: 15.minutes

      argument :set_password_attributes, Types::Auth::ResetPasswordAttributesInput,
               description: "New password and the token from validateOtp"

      field :token, String, null: false, description: "Send as `Authorization: Bearer <token>` on later requests"
      field :user, Types::Users::UserType, null: false, description: "The signed-in user"

      def resolve(set_password_attributes:)
        session = value_or_raise!(::Auth::ResetPassword.call(**set_password_attributes.to_h))
        { token: session.token, user: session.user }
      end
    end
  end
end
