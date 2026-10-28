module Mutations
  module Auth
    class ResetPassword < BaseMutation
      description "Sets a new password with the token from the reset email, signs out every device and signs in"

      allow_unauthenticated!

      argument :reset_password_attributes, Types::Auth::ResetPasswordAttributesInput,
               description: "Token and new password"

      field :token, String, null: false, description: "Send as `Authorization: Bearer <token>` on later requests"
      field :user, Types::Users::UserType, null: false, description: "The signed-in user"

      def resolve(reset_password_attributes:)
        session = value_or_raise!(::Auth::ResetPassword.call(**reset_password_attributes.to_h))
        { token: session.token, user: session.user }
      end
    end
  end
end
