# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    description "Write operations"
    field :accept_invitation, mutation: Mutations::Auth::AcceptInvitation
    field :archive_user, mutation: Mutations::Users::ArchiveUser
    field :create_invitation, mutation: Mutations::Invitations::CreateInvitation
    field :delete_invitation, mutation: Mutations::Invitations::DeleteInvitation
    field :login_user, mutation: Mutations::Auth::LoginUser
    field :logout, mutation: Mutations::Auth::Logout
    field :resend_invitation, mutation: Mutations::Invitations::ResendInvitation
    field :reset_password, mutation: Mutations::Auth::ResetPassword
    field :send_reset_password_instructions, mutation: Mutations::Auth::SendResetPasswordInstructions
    field :update_password, mutation: Mutations::Users::UpdatePassword
    field :update_user, mutation: Mutations::Users::UpdateUser
  end
end
