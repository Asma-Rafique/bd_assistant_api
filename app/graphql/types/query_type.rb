# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    description "Read operations"

    field :api_status, resolver: Queries::System::ApiStatus
    field :current_user, resolver: Queries::Users::CurrentUser
  end
end
