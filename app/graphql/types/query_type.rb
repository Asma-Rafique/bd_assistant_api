# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    description "Read operations"

    field :api_status, resolver: Queries::System::ApiStatus
    field :protected_ping, resolver: Queries::System::ProtectedPing
  end
end
