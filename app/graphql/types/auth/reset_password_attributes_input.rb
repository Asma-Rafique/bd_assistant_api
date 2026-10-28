module Types
  module Auth
    class ResetPasswordAttributesInput < Types::BaseInputObject
      description "The token from the reset email, and the new password"

      argument :token, String, description: "The token from the reset link"
      argument :password, String, description: "8+ characters with upper, lower and special characters"
      argument :password_confirmation, String, description: "Must match password"
    end
  end
end
