module Auth
  # Checks an email and password. A user with OTP switched on gets an emailed
  # login code that VerifySignInCode exchanges for a session; anyone else is
  # signed in at once.
  class Login < ApplicationService
    def initialize(email:, password:)
      @email = email
      @password = password
    end

    def call
      user = User.authenticate_by(email: @email, password: @password)
      return failure(:invalid_credentials) unless user
      return failure(:sign_in_blocked) unless user.can_sign_in?

      if user.otp_enabled?
        OneTimePasswords::SendCode.call(user:, purpose: :login)
        success(SignInOutcome.new(user:, session: nil))
      else
        success(SignInOutcome.new(user:, session: user.sign_in!))
      end
    end
  end
end
