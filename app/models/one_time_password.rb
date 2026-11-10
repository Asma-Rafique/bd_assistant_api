# A 6-digit code emailed to the user, for signing in or resetting a password.
# A user has at most one live code per purpose: issuing a new one replaces the
# old. Only an HMAC of the code is stored, so a database leak reveals no codes.
class OneTimePassword < ApplicationRecord
  CODE_LENGTH = 6
  TTL = 10.minutes
  MAX_FAILED_ATTEMPTS = 5
  RESEND_COOLDOWN = 30.seconds

  belongs_to :user

  enum :purpose, { login: 0, password_reset: 1 }, validate: true

  # Creates or replaces the user's code for this purpose in one statement, and
  # returns the plain code for the email.
  def self.issue!(user:, purpose:)
    code = SecureRandom.random_number(10**CODE_LENGTH).to_s.rjust(CODE_LENGTH, "0")

    upsert(
      { user_id: user.id, purpose: purposes.fetch(purpose.to_s), code_digest: digest(code),
        failed_attempts: 0, expires_at: TTL.from_now },
      unique_by: %i[user_id purpose]
    )

    code
  end

  # The code waiting to be entered for this email and purpose, if any. The
  # purpose keeps the flows apart: a login code can't reset a password.
  def self.pending_for(email, purpose:)
    includes(:user).joins(:user)
                   .find_by(purpose: purpose.to_s, users: { email: User.normalize_value_for(:email, email) })
  end

  # An HMAC rather than a plain hash: there are only a million 6-digit codes,
  # so a plain hash could be reversed by trying them all.
  def self.digest(code)
    OpenSSL::HMAC.hexdigest("SHA256", digest_key, code.to_s)
  end

  def self.digest_key
    @digest_key ||= Rails.application.key_generator.generate_key("one_time_password")
  end

  # The code reaches the email job encrypted, so Redis, where queued and
  # retrying jobs wait, never holds a live code. The message expires with the
  # code: decrypting a late retry's copy gives nil.
  def self.encrypt_for_email(code) = email_encryptor.encrypt_and_sign(code, expires_in: TTL)
  def self.decrypt_for_email(encrypted_code) = email_encryptor.decrypt_and_verify(encrypted_code)

  def self.email_encryptor
    @email_encryptor ||= ActiveSupport::MessageEncryptor.new(
      Rails.application.key_generator.generate_key("one_time_password_email", ActiveSupport::MessageEncryptor.key_len)
    )
  end

  def issued_at = expires_at - TTL
  def expired? = expires_at.past?
  def locked? = failed_attempts >= MAX_FAILED_ATTEMPTS

  # A code that can no longer be used is replaced at once; a working one only
  # after the cooldown, so the email already sent keeps working.
  def resendable? = expired? || locked? || issued_at <= RESEND_COOLDOWN.ago

  # A wrong guess is counted, so the code stops working after MAX_FAILED_ATTEMPTS
  # and can't be found by trying every number.
  def correct_code?(code)
    return false if expired? || locked?
    return true if ActiveSupport::SecurityUtils.secure_compare(code_digest, self.class.digest(code))

    increment!(:failed_attempts)
    false
  end
end
