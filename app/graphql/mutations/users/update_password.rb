module Mutations
  module Users
    class UpdatePassword < BaseMutation
      description "Changes the signed-in user's password and signs out their other devices"

      argument :update_password_attributes, Types::Users::UpdatePasswordAttributesInput,
               description: "Current and new password"

      field :success, Boolean, null: false, description: "True when the password was changed"

      def resolve(update_password_attributes:)
        value_or_raise!(::Users::ChangePassword.call(user: current_user, current_session:,
                                                     **update_password_attributes.to_h))
        { success: true }
      end
    end
  end
end
