module Auth
  # Exchanges an emailed code for a session. The code works once: it's deleted
  # as soon as it's accepted.
  class VerifySignInCode < ApplicationService
    def initialize(email:, code:, purpose:)
      @email = email
      @code = code
      @purpose = purpose
    end

    def call
      one_time_password = OneTimePassword.pending_for(@email, purpose: @purpose)
      return code_rejected(one_time_password) unless one_time_password&.correct_code?(@code)

      user = one_time_password.user
      return failure(:sign_in_blocked) unless user.can_sign_in?

      one_time_password.destroy!
      success(SignInOutcome.new(user:, session: user.sign_in!))
    end

    private

    # A locked code gets its own message, so the user asks for a new one
    # instead of trying again.
    def code_rejected(one_time_password)
      key = one_time_password&.locked? ? "errors.code_locked" : "errors.invalid_code"
      failure(:invalid_code, I18n.t(key))
    end
  end
end
