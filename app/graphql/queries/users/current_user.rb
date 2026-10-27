module Queries
  module Users
    class CurrentUser < BaseQuery
      description "The signed-in user"

      type Types::Users::UserType, null: false

      def resolve = current_user
    end
  end
end
