module Auth
  # Exchanges an emailed code for a session (login) or a short-lived password
  # reset token (password reset), depending on why it was sent. The code works
  # once: it's deleted as soon as it's accepted.
  class VerifySignInCode < ApplicationService
    Outcome = Data.define(:user, :session, :password_reset_token)

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
      success(one_time_password.login? ? sign_in(user) : password_reset(user))
    end

    private

    def sign_in(user) = Outcome.new(user:, session: user.sign_in!, password_reset_token: nil)

    # No session yet: the user signs in once SetPassword uses the token.
    def password_reset(user) = Outcome.new(user:, session: nil, password_reset_token: user.password_reset_token)

    # A locked code gets its own message, so the user asks for a new one
    # instead of trying again.
    def code_rejected(one_time_password)
      key = one_time_password&.locked? ? "errors.code_locked" : "errors.invalid_code"
      failure(:invalid_code, I18n.t(key))
    end
  end
end
