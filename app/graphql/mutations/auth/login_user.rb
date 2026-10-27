module Mutations
  module Auth
    class LoginUser < BaseMutation
      description "Signs in with email and password, and returns a bearer token for the Authorization header"

      allow_unauthenticated!

      argument :login_attributes, Types::Auth::LoginAttributesInput, description: "Email and password"

      field :token, String, null: false, description: "Send as `Authorization: Bearer <token>` on later requests"
      field :user, Types::Users::UserType, null: false, description: "The signed-in user"

      def resolve(login_attributes:)
        session = value_or_raise!(::Auth::Login.call(**login_attributes.to_h))
        { token: session.token, user: session.user }
      end
    end
  end
end
