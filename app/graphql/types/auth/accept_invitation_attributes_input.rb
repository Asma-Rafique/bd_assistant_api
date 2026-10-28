module Types
  module Auth
    class AcceptInvitationAttributesInput < Types::BaseInputObject
      description "The token from the invitation email, and the new user's password"

      argument :token, String, description: "The token from the invitation link"
      argument :password, String, description: "8+ characters with upper, lower and special characters"
      argument :password_confirmation, String, description: "Must match password"
    end
  end
end
