# Values for the current request only: Rails gives each request its own copy
# and resets them when the request (or background job) finishes.
class Current < ActiveSupport::CurrentAttributes
  attribute :ip_address, :user_agent
end
