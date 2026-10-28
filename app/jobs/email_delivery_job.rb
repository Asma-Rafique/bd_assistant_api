# Sends every deliver_later email. It replaces Rails' default job so the
# email's arguments (such as the user) never appear in the logs.
class EmailDeliveryJob < ActionMailer::MailDeliveryJob
  self.log_arguments = false

  # The user was deleted before the job ran: there's no one to email.
  discard_on ActiveJob::DeserializationError
end
