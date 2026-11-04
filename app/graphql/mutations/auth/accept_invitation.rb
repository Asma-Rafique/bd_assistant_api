module Mutations
  module Auth
    class AcceptInvitation < BaseMutation
      description "Sets the password for an invited account with the token from the email, and signs in"

      allow_unauthenticated!
      rate_limit to: 10, within: 15.minutes

      argument :accept_invitation_attributes, Types::Auth::AcceptInvitationAttributesInput,
               description: "Token and password"

      field :token, String, null: false, description: "Send as `Authorization: Bearer <token>` on later requests"
      field :user, Types::Users::UserType, null: false, description: "The signed-in user"

      def resolve(accept_invitation_attributes:)
        session = value_or_raise!(::Auth::AcceptInvitation.call(**accept_invitation_attributes.to_h))
        { token: session.token, user: session.user }
      end
    end
  end
end
