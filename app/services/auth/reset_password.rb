module Auth
  # Sets a new password with the token from validateOtp, signs out every device and
  # starts a fresh session.
  class ResetPassword < ApplicationService
    def initialize(token:, password:, password_confirmation:)
      @token = token
      @password = password
      @password_confirmation = password_confirmation
    end

    def call
      user = User.find_by_password_reset_token(@token)
      return failure(:invalid_token) unless user&.can_sign_in?
      return invalid(user) unless user.update_password(password: @password,
                                                       password_confirmation: @password_confirmation)

      success(Session.start_for!(user))
    end
  end
end
