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
  # before the email is queued. So it arrives encrypted, and an expired one
  # (a retry that ran too late) sends nothing.
  def verification_code
    @user = params[:user]
    @code = OneTimePassword.decrypt_for_email(params[:encrypted_code])
    return unless @code

    @purpose = params[:purpose]
    @minutes = OneTimePassword::TTL.in_minutes.to_i

    mail to: @user.email, subject: t(".subject.#{@purpose}")
  end
end
