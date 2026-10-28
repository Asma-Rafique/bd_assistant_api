module Users
  # Changes a signed-in user's password. The current device stays signed in;
  # every other one is signed out.
  class ChangePassword < ApplicationService
    def initialize(user:, current_password:, password:, password_confirmation:, current_session: nil)
      @user = user
      @current_password = current_password
      @password = password
      @password_confirmation = password_confirmation
      @current_session = current_session
    end

    def call
      unless @user.authenticate(@current_password)
        return failure(:invalid_credentials, I18n.t("errors.current_password_invalid"))
      end

      updated = @user.update_password(password: @password, password_confirmation: @password_confirmation,
                                      keep_session: @current_session)
      updated ? success(@user) : invalid(@user)
    end
  end
end
