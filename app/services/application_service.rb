# One business operation per subclass, exposed as `.call(...)`. Expected
# failures come back as a ServiceResult; unexpected ones raise.
class ApplicationService
  def self.call(...) = new(...).call

  private

  def success(value = nil) = ServiceResult.success(value)

  def failure(code, message = I18n.t("errors.#{code}"))
    ServiceResult.failure(ServiceError.new(code:, message:))
  end

  def invalid(record) = ServiceResult.failure(ServiceError.from_record(record))
end
