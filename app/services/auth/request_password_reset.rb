module Auth
  # Always succeeds, so the answer never reveals whether an account exists.
  class RequestPasswordReset < ApplicationService
    def initialize(email:)
      @email = email
    end

    def call
      user = User.find_by(email: @email)
      UserMailer.with(user:).password_reset.deliver_later if user&.can_sign_in?
      success
    end
  end
end
