# Counts attempts in a fixed time window, in the shared cache. The
# discriminator (an email, an IP) is hashed so emails never appear in cache
# keys, and case-folded so "Sam@x.com" and "sam@x.com " share one budget.
class RateLimiter
  def initialize(scope:, discriminator:, limit:, period:)
    @key = "rate_limit:#{scope}:#{OpenSSL::Digest::SHA256.hexdigest(discriminator.to_s.strip.downcase)}"
    @limit = limit
    @period = period
  end

  # Counts this attempt, then says whether the window's budget is used up.
  def exceeded?
    Rails.cache.increment(@key, 1, expires_in: @period).to_i > @limit
  end
end
