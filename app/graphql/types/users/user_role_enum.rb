module Types
  module Users
    class UserRoleEnum < Types::BaseEnum
      description "What a user is allowed to do"

      value "team_member", "A BD team member: works with opportunities and proposals", value: "team_member"
      value "super_admin", "An administrator: also manages users and settings", value: "super_admin"
    end
  end
end
