module Types
  module Users
    class UserFilterInput < PaginatedFilterInput
      description "Filters and paging for the user list"

      argument :role, UserRoleEnum, required: false, description: "Only users with this role"
      argument :search, String, required: false, description: "Matches email, first name or last name"
      argument :archived, Boolean, required: false, description: "True for archived users only, false to exclude them"
    end
  end
end
