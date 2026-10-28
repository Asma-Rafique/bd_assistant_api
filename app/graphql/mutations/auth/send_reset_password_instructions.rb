module Mutations
  module Auth
    class SendResetPasswordInstructions < BaseMutation
      description "Emails a password reset link when the account exists. Continue with resetPassword."

      allow_unauthenticated!

      argument :email, String, description: "Account email address, in any letter case"

      field :message, String, null: false,
                              description: "Always the same, so it never reveals whether the account exists"

      def resolve(email:)
        ::Auth::RequestPasswordReset.call(email:)
        { message: I18n.t("auth.password_reset_requested") }
      end
    end
  end
end
