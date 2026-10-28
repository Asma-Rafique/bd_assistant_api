class ApplicationJob < ActiveJob::Base
  # A deadlock is temporary: try again.
  retry_on ActiveRecord::Deadlocked

  # The record was deleted before the job ran: nothing to do, and a retry can't help.
  discard_on ActiveJob::DeserializationError
end
