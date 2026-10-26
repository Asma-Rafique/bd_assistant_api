# Shared by every query and mutation. Login is required by default;
# an operation opts out with allow_unauthenticated!.
module GraphqlOperation
  extend ActiveSupport::Concern

  included do
    include ActionPolicy::Behaviour

    authorize :user, through: :current_user

    class_attribute :authentication_required, default: true
  end

  class_methods do
    def allow_unauthenticated!
      self.authentication_required = false
    end
  end

  def ready?(**arguments)
    raise GraphqlErrors.unauthenticated if authentication_required && current_user.nil?

    super
  end

  private

  def current_user = context[:current_user]
end
