module Mutations
  module Invitations
    class CreateInvitation < BaseMutation
      description "Super admins only: invites up to 20 people by email. Either all are invited or none are."

      argument :emails, [String], description: "Addresses to invite"
      argument :role, Types::Users::UserRoleEnum, description: "The role the invited users will have"

      field :message, String, null: false, description: "Confirmation message"
      field :users, [Types::Users::UserType], null: false, description: "The invited users"

      def resolve(emails:, role:)
        authorize! User, to: :invite?

        users = value_or_raise!(::Invitations::SendInvitations.call(emails:, role:, invited_by: current_user))
        { message: I18n.t("invitations.sent", count: users.size), users: }
      end
    end
  end
end
