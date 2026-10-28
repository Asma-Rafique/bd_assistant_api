# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    description "Write operations"

    field :login_user, mutation: Mutations::Auth::LoginUser
    field :logout, mutation: Mutations::Auth::Logout
    field :reset_password, mutation: Mutations::Auth::ResetPassword
    field :send_reset_password_instructions, mutation: Mutations::Auth::SendResetPasswordInstructions
    field :update_password, mutation: Mutations::Users::UpdatePassword
  end
end
