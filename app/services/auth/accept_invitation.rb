module Auth
  # Sets the password for an invited account from the emailed link and signs
  # the new user in.
  class AcceptInvitation < ApplicationService
    def initialize(token:, password:, password_confirmation:)
      @token = token
      @password = password
      @password_confirmation = password_confirmation
    end

    def call
      user = User.find_by_invitation_token(@token)
      return failure(:invalid_token) unless user
      return invalid(user) unless user.accept_invitation(password: @password,
                                                         password_confirmation: @password_confirmation)

      success(Session.start_for!(user))
    end
  end
end
