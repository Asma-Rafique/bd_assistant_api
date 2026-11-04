# Shared by every query and mutation. Login is required by default;
# an operation opts out with allow_unauthenticated!.
module GraphqlOperation
  extend ActiveSupport::Concern

  RateLimitRule = Data.define(:limit, :period, :discriminator)

  included do
    include ActionPolicy::Behaviour

    authorize :user, through: :current_user

    class_attribute :authentication_required, default: true
    class_attribute :rate_limit_rules, default: []
  end

  class_methods do
    def allow_unauthenticated!
      self.authentication_required = false
    end

    # `by` picks what to count per (an email, the current user's id); it runs
    # on the operation with its arguments. Without it, counts per client IP.
    # Declare it more than once to enforce several limits at once.
    def rate_limit(to:, within:, by: nil)
      self.rate_limit_rules += [RateLimitRule.new(limit: to, period: within, discriminator: by)]
    end
  end

  def ready?(**arguments)
    raise GraphqlErrors.unauthenticated if authentication_required && current_user.nil?
    raise GraphqlErrors.rate_limited if rate_limit_exceeded?(arguments)

    super
  end

  private

  def current_user = context[:current_user]
  def current_session = context[:current_session]

  def value_or_raise!(result)
    raise GraphqlErrors.from_service_error(result.error) if result.failure?

    result.value
  end

  # Runs once per copy of the operation in a request, so aliased copies each
  # count. Stops at the first rule that's used up.
  def rate_limit_exceeded?(arguments)
    rate_limit_rules.each_with_index.any? do |rule, index|
      discriminator = rule.discriminator ? instance_exec(arguments, &rule.discriminator) : context[:ip_address]
      RateLimiter.new(scope: "#{self.class.name}:#{index}", discriminator:,
                      limit: rule.limit, period: rule.period).exceeded?
    end
  end
end
