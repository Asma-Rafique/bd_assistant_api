class InvitationMailer < ApplicationMailer
  # Like the reset email, the token is made when the email is sent, so it
  # never sits in Redis inside the job's arguments.
  def invitation
    @user = params[:user]
    @inviter_name = @user.invited_by&.full_name
    query = { token: @user.generate_token_for(:invitation) }.to_query
    @accept_url = "#{Rails.configuration.x.frontend_url}/accept-invitation?#{query}"
    @valid_for_days = User::INVITATION_TTL.in_days.to_i

    mail to: @user.email, subject: t(".subject")
  end
end
