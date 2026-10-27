# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    description "Write operations"

    field :login_user, mutation: Mutations::Auth::LoginUser
    field :logout, mutation: Mutations::Auth::Logout
  end
end
