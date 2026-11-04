module Mutations
  module Invitations
    class DeleteInvitation < BaseMutation
      description "Super admins only: cancels an invitation that hasn't been accepted, removing the account"

      argument :id, ID, description: "The invited user"

      field :message, String, null: false, description: "Confirmation message"

      def resolve(id:)
        user = authorized_scope(User.all).find(id)
        authorize! user, to: :destroy_invitation?

        user.destroy!
        { message: I18n.t("invitations.deleted") }
      end
    end
  end
end
