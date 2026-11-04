module Queries
  module Auth
    class ValidateInvitationToken < BaseQuery
      description "Checks an invitation link before the frontend shows the set-password form"

      allow_unauthenticated!

      type Types::Auth::InvitationTokenValidationType, null: false

      argument :token, String, description: "The token from the invitation link"

      def resolve(token:)
        return { valid: true, error: nil } if User.find_by_invitation_token(token)

        { valid: false, error: I18n.t("errors.invalid_token") }
      end
    end
  end
end
