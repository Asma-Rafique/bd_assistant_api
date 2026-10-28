module Invitations
  # Invites a batch of people in one transaction: either every address is
  # invited or none is.
  class SendInvitations < ApplicationService
    MAX_EMAILS = 20

    def initialize(emails:, role:, invited_by:)
      @emails = emails.map { User.normalize_value_for(:email, it) }.uniq
      @role = role
      @invited_by = invited_by
    end

    def call
      return failure(:validation_failed, batch_size_message) unless @emails.size.between?(1, MAX_EMAILS)
      return failure(:validation_failed, taken_emails_message) if taken_emails.any?

      invitees = @emails.map { build_invitee(it) }
      invalid_invitee = invitees.find(&:invalid?)
      return invalid(invalid_invitee) if invalid_invitee

      save_and_notify(invitees)
      success(invitees)
    end

    private

    # Emails go out only after every user is saved, so a failed batch sends nothing.
    def save_and_notify(invitees)
      User.transaction { invitees.each(&:save!) }
      invitees.each { InvitationMailer.with(user: it).invitation.deliver_later }
    end

    def batch_size_message = I18n.t("errors.invitation_count", count: MAX_EMAILS)
    def taken_emails_message = I18n.t("errors.emails_taken", emails: taken_emails.to_sentence)

    def taken_emails
      @taken_emails ||= User.where(email: @emails).pluck(:email)
    end

    def build_invitee(email)
      User.new(email:, role: @role, invited_by: @invited_by, invitation_sent_at: Time.current)
    end
  end
end
