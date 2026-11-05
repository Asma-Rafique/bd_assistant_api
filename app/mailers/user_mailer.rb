class UserMailer < ApplicationMailer
  # The token is made here, when the email is sent, so it never sits in Redis
  # inside the job's arguments.
  def password_reset
    @user = params[:user]
    query = { token: @user.password_reset_token }.to_query
    @reset_url = "#{Rails.configuration.x.frontend_url}/reset-password?#{query}"

    mail to: @user.email, subject: t(".subject")
  end

  # Unlike the reset token, the code can't be made here: its digest is saved
  # before the email is queued. EmailDeliveryJob keeps it out of the logs.
  def verification_code
    @user = params[:user]
    @code = params[:code]
    @purpose = params[:purpose]
    @minutes = OneTimePassword::TTL.in_minutes.to_i

    mail to: @user.email, subject: t(".subject.#{@purpose}")
  end
end
