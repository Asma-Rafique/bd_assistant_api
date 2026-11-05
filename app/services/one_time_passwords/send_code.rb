module OneTimePasswords
  # Issues a new code for the purpose, replacing any earlier one, and emails it.
  class SendCode < ApplicationService
    def initialize(user:, purpose:)
      @user = user
      @purpose = purpose.to_s
    end

    def call
      code = OneTimePassword.issue!(user: @user, purpose: @purpose)
      UserMailer.with(user: @user, code:, purpose: @purpose).verification_code.deliver_later
      success
    end
  end
end
