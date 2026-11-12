module Auth
  # Emails a new code for a sign-in or password reset already in progress. It
  # never starts one, so it can't be used to skip the password check.
  class ResendSignInCode < ApplicationService
    def initialize(email:, purpose:)
      @email = email
      @purpose = purpose
    end

    def call
      one_time_password = OneTimePassword.pending_for(@email, purpose: @purpose)
      return failure(:invalid_code, I18n.t("errors.code_not_pending")) unless one_time_password
      return failure(:rate_limited, I18n.t("errors.resend_cooldown")) unless one_time_password.resendable?

      OneTimePasswords::SendCode.call(user: one_time_password.user, purpose: @purpose)
    end
  end
end
