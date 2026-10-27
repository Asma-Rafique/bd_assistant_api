module Queries
  module Users
    class FetchUser < BaseQuery
      description "Returns one user. Super admins may fetch anyone; team members only themselves."

      type Types::Users::UserType, null: false

      argument :id, ID, description: "The user to fetch"

      def resolve(id:)
        user = authorized_scope(User.all).find(id)
        authorize! user, to: :show?
        user
      end
    end
  end
end
