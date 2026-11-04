module Queries
  module Users
    class AllUsers < BaseQuery
      include Paginatable

      description "Super admins only: a filtered, paginated list of users, newest first"

      type Types::Users::UserPaginationType, null: false

      argument :filters, Types::Users::UserFilterInput, required: false, description: "Filters and paging"

      def resolve(filters: nil)
        authorize! User, to: :index?

        options = filters.to_h
        users = ::Users::FilterQuery.new(authorized_scope(User.all)).call(**filters_without_paging(options))
        paginate_with_filter(users, options)
      end
    end
  end
end
