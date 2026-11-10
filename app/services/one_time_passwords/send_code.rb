module OneTimePasswords
  # Issues a new code for the purpose, replacing any earlier one, and emails it.
  # Within the resend cooldown it sends nothing: the code already emailed still
  # works, and a second email would replace it with one the user hasn't seen.
  class SendCode < ApplicationService
    def initialize(user:, purpose:)
      @user = user
      @purpose = purpose.to_s
    end

    def call
      current = OneTimePassword.find_by(user: @user, purpose: @purpose)
      return failure(:rate_limited, I18n.t("errors.resend_cooldown")) if current && !current.resendable?

      code = OneTimePassword.issue!(user: @user, purpose: @purpose)
      encrypted_code = OneTimePassword.encrypt_for_email(code)
      UserMailer.with(user: @user, encrypted_code:, purpose: @purpose).verification_code.deliver_later
      success
    end
  end
end
