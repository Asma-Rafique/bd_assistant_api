module Mutations
  module Users
    class UpdateOtpSetting < BaseMutation
      description "Switches the emailed sign-in code on or off for the signed-in user"

      rate_limit to: 5, within: 15.minutes, by: ->(_arguments) { current_user.id }

      argument :enabled, Boolean, description: "True to ask for an emailed code after the password"
      argument :current_password, String, description: "The password in use today"

      field :user, Types::Users::UserType, null: false, description: "The user with the new setting"

      def resolve(enabled:, current_password:)
        user = value_or_raise!(::Users::UpdateOtpSetting.call(user: current_user, enabled:, current_password:))
        { user: }
      end
    end
  end
end
