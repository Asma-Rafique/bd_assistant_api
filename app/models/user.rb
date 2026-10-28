# app/models/user.rb
class User < ApplicationRecord
  EMAIL_MAX_LENGTH = 254

  has_secure_password
  has_many :sessions, dependent: :delete_all

  enum :role, { team_member: 0, super_admin: 1 }, validate: true

  normalizes :email, with: -> { it.strip.downcase }

  validates :email, presence: true, uniqueness: true, length: { maximum: EMAIL_MAX_LENGTH },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, password_strength: true, allow_nil: true

  def full_name = [first_name, last_name].compact.join(" ").presence

  def archived? = archived_at.present?
  def can_sign_in? = !archived?

  # Changes the password and signs out every other device, so a stolen token
  # stops working along with the old password.
  def update_password(password:, password_confirmation:, keep_session: nil)
    transaction do
      update(password:, password_confirmation:).tap do |updated|
        sessions.where.not(id: keep_session).delete_all if updated
      end
    end
  end
end
