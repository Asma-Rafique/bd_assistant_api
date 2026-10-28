class UserMailer < ApplicationMailer
  # The token is made here, when the email is sent, so it never sits in Redis
  # inside the job's arguments.
  def password_reset
    @user = params[:user]
    query = { token: @user.password_reset_token }.to_query
    @reset_url = "#{Rails.configuration.x.frontend_url}/reset-password?#{query}"

    mail to: @user.email, subject: t(".subject")
  end
end
