module Types
  module Users
    class UserType < Types::BaseObject
      description "A person who can sign in"

      field :id, ID, null: false, description: "Unique identifier"
      field :email, String, null: false, description: "Sign-in email address"
      field :first_name, String, description: "Given name"
      field :last_name, String, description: "Family name"
      field :full_name, String, description: "First and last name joined, or null when neither is set"
      field :role, UserRoleEnum, null: false, description: "What the user is allowed to do"
      field :archived_at, GraphQL::Types::ISO8601DateTime, description: "When the user was archived, or null"
      field :last_sign_in_at, GraphQL::Types::ISO8601DateTime, description: "When the user last signed in"
      field :created_at, GraphQL::Types::ISO8601DateTime, null: false, description: "When the account was created"
    end
  end
end
