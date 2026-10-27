class UserPolicy < ApplicationPolicy
  # The users a caller may see at all: super admins see everyone, team
  # members only themselves.
  relation_scope do |relation|
    super_admin? ? relation : relation.where(id: user.id)
  end

  def show? = super_admin? || own_account?

  private

  def own_account? = record.id == user.id
end
