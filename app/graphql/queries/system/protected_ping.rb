module Queries
  module System
    class ProtectedPing < BaseQuery
      description 'Returns "pong" when you are logged in. Temporary: B4 replaces it with currentUser.'

      type String, null: false

      def resolve = "pong"
    end
  end
end
