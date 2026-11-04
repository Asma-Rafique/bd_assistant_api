module Types
  module Auth
    class InvitationTokenValidationType < Types::BaseObject
      description "Whether an invitation link can still be used"

      field :valid, Boolean, null: false, description: "True when the invitation can be accepted"
      field :error, String, description: "Why the invitation can't be used, or null"
    end
  end
end
