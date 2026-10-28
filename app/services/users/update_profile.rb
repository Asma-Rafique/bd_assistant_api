module Users
  class UpdateProfile < ApplicationService
    def initialize(user:, attributes:)
      @user = user
      @attributes = attributes
    end

    def call
      return invalid(@user) unless @user.update(@attributes)

      success(@user)
    end
  end
end
