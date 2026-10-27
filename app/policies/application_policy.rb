# Base class for every policy. A rule reads `user` (who is asking) and
# `record` (what they are asking about).
class ApplicationPolicy < ActionPolicy::Base
  authorize :user

  private

  def super_admin? = user.super_admin?
end
