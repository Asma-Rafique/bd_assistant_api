module Auth
  # Checks an email and password and, if they match an account that may sign
  # in, starts a new session for it.
  class Login < ApplicationService
    def initialize(email:, password:)
      @email = email
      @password = password
    end

    def call
      user = User.authenticate_by(email: @email, password: @password)
      return failure(:invalid_credentials) unless user
      return failure(:sign_in_blocked) unless user.can_sign_in?

      user.touch(:last_sign_in_at)
      success(Session.start_for!(user))
    end
  end
end
