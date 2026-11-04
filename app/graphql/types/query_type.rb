# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    description "Read operations"
    field :all_users, resolver: Queries::Users::AllUsers
    field :api_status, resolver: Queries::System::ApiStatus
    field :current_user, resolver: Queries::Users::CurrentUser
    field :fetch_user, resolver: Queries::Users::FetchUser
    field :validate_invitation_token, resolver: Queries::Auth::ValidateInvitationToken
  end
end
