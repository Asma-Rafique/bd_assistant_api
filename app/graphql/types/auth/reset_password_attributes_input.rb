module Types
  module Auth
    class ResetPasswordAttributesInput < Types::BaseInputObject
      description "The token from validateOtp, and the new password"

      argument :reset_password_token, String, as: :token,
                                              description: "The token from validateOtp, valid for 15 minutes"
      argument :password, String, description: "8+ characters with upper, lower and special characters"
      argument :password_confirmation, String, description: "Must match password"
    end
  end
end
