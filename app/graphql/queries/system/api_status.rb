module Queries
  module System
    class ApiStatus < BaseQuery
      description 'Returns "ok" when the API is up. Needs no login.'

      allow_unauthenticated!

      type String, null: false

      def resolve = "ok"
    end
  end
end
