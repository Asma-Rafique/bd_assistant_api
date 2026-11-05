module Types
  module Auth
    class SignInPurposeEnum < Types::BaseEnum
      description "Which emailed code a code screen is checking"

      value "login", "The code emailed by loginUser", value: "login"
      value "password_reset", "The code emailed by sendResetPasswordInstructions", value: "password_reset"
    end
  end
end
