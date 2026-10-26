# An expected business failure. The code becomes the GraphQL error's
# extensions.code, so it is part of the API contract.
class ServiceError < Data.define(:code, :message, :field_errors)
  CODES = %i[validation_failed].freeze

  def self.from_record(record)
    new(
      code: :validation_failed,
      message: record.errors.full_messages.to_sentence,
      field_errors: record.errors.map { { "field" => it.attribute.to_s.camelize(:lower), "message" => it.message } }
    )
  end

  def initialize(code:, message:, field_errors: [])
    raise ArgumentError, "Unknown service error code: #{code}" unless CODES.include?(code)

    super
  end
end
