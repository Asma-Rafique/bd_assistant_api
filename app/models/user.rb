class User < ApplicationRecord
  EMAIL_MAX_LENGTH = 254
  INVITATION_TTL = 7.days

  # Invited users have no password until they accept, so the built-in
  # presence check is replaced by password_must_be_set below.
  has_secure_password validations: false
  has_many :sessions, dependent: :delete_all
  belongs_to :invited_by, class_name: "User", optional: true

  enum :role, { team_member: 0, super_admin: 1 }, validate: true

  normalizes :email, with: -> { it.strip.downcase }

  # Resending or accepting changes one of these timestamps, which makes every
  # earlier invitation link invalid.
  generates_token_for :invitation, expires_in: INVITATION_TTL do
    [invitation_sent_at, invitation_accepted_at]
  end

  validates :email, presence: true, uniqueness: true, length: { maximum: EMAIL_MAX_LENGTH },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :password_must_be_set, unless: :invitation_pending?
  validates :password, password_strength: true, confirmation: true, allow_nil: true
  scope :archived, -> { where.not(archived_at: nil) }
  scope :not_archived, -> { where(archived_at: nil) }
  scope :invitation_pending, -> { where.not(invitation_sent_at: nil).where(invitation_accepted_at: nil) }

  def self.find_by_invitation_token(token)
    user = find_by_token_for(:invitation, token)
    user if user&.invitation_acceptable?
  end

  def full_name = [first_name, last_name].compact.join(" ").presence

  def archived? = archived_at.present?
  def invitation_pending? = invitation_sent_at.present? && invitation_accepted_at.nil?
  def invitation_acceptable? = invitation_pending? && !archived?
  def can_sign_in? = !archived? && !invitation_pending?

  # Changes the password and signs out every other device, so a stolen token
  # stops working along with the old password.
  def update_password(password:, password_confirmation:, keep_session: nil)
    transaction do
      update(password:, password_confirmation:).tap do |updated|
        sessions.where.not(id: keep_session).delete_all if updated
      end
    end
  end

  # Signs the user out everywhere, so an archived account loses access at once.
  def archive!
    transaction do
      update!(archived_at: Time.current)
      sessions.delete_all
    end
  end

  def unarchive!
    update!(archived_at: nil)
  end

  def accept_invitation(password:, password_confirmation:)
    update(password:, password_confirmation:, invitation_accepted_at: Time.current)
  end

  private

  def password_must_be_set
    errors.add(:password, :blank) if password_digest.blank?
  end
end
