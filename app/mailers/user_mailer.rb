class UserMailer < ApplicationMailer
  # The code can't be made here: its digest is saved before the email is
  # queued. EmailDeliveryJob keeps it out of the logs.
  def verification_code
    @user = params[:user]
    @code = params[:code]
    @purpose = params[:purpose]
    @minutes = OneTimePassword::TTL.in_minutes.to_i

    mail to: @user.email, subject: t(".subject.#{@purpose}")
  end
end
