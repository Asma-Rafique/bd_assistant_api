module Mutations
  module Auth
    class Logout < BaseMutation
      description "Ends the current session. Its token stops working immediately."

      field :message, String, null: false, description: "Confirmation message"

      def resolve
        current_session.destroy!
        { message: I18n.t("auth.logged_out") }
      end
    end
  end
end
