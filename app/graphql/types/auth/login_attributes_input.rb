module Types
  module Auth
    class LoginAttributesInput < Types::BaseInputObject
      description "Email and password for signing in"

      argument :email, String, description: "Account email address, in any letter case"
      argument :password, String, description: "Account password"
    end
  end
end
