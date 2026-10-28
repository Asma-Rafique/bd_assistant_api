module Types
  module Users
    class UserAttributesInput < BaseInputObject
      description "Profile fields to change. Omitted fields stay as they are."

      argument :first_name, String, required: false, description: "Given name"
      argument :last_name, String, required: false, description: "Family name"
    end
  end
end
