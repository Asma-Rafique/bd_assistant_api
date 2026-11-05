module Users
  # Switches the emailed sign-in code on or off for a signed-in user. It needs
  # the current password, so a stolen token alone can't switch it off.
  class UpdateOtpSetting < ApplicationService
    def initialize(user:, enabled:, current_password:)
      @user = user
      @enabled = enabled
      @current_password = current_password
    end

    def call
      unless @user.authenticate(@current_password)
        return failure(:invalid_credentials, I18n.t("errors.current_password_invalid"))
      end

      @user.update!(otp_enabled: @enabled)
      success(@user)
    end
  end
end
