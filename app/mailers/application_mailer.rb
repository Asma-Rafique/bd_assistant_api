class ApplicationMailer < ActionMailer::Base
  self.delivery_job = EmailDeliveryJob
  default from: -> { ENV.fetch("MAILER_SENDER", "BD Assistant <no-reply@example.com>") }
  layout "mailer"
end
