module Types
  module Auth
    class SignInPurposeEnum < Types::BaseEnum
      description "Which emailed code a code screen is checking"

      value "login", "The code emailed by loginUser", value: "login"
    end
  end
end
