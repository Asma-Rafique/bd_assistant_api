module Types
  module Users
    class UpdatePasswordAttributesInput < Types::BaseInputObject
      description "The current password, and the new one"

      argument :current_password, String, description: "The password in use today"
      argument :password, String, description: "8+ characters with upper, lower and special characters"
      argument :password_confirmation, String, description: "Must match password"
    end
  end
end
