# frozen_string_literal: true

module GraphqlErrors
  module_function

  def unauthenticated
    build(I18n.t("errors.unauthenticated"), :unauthenticated)
  end

  def forbidden
    build(I18n.t("errors.forbidden"), :forbidden)
  end

  def not_found(resource: nil)
    build(I18n.t("errors.not_found"), :not_found, resource: resource)
  end

  def rate_limited
    build(I18n.t("errors.rate_limited"), :rate_limited)
  end

  def internal
    build(I18n.t("errors.internal"), :internal)
  end

  def from_service_error(error)
    build(error.message, error.code, fieldErrors: error.field_errors.presence)
  end

  def build(message, code, **extensions)
    GraphQL::ExecutionError.new(
      message,
      extensions: { code: code.to_s.upcase, **extensions.compact }
    )
  end
end
