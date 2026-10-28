class UserPolicy < ApplicationPolicy
  # The users a caller may see at all: super admins see everyone, team
  # members only themselves.
  relation_scope do |relation|
    super_admin? ? relation : relation.where(id: user.id)
  end

  def index? = super_admin?
  def show? = super_admin? || own_account?
  def update? = super_admin? || own_account?

  # Admin actions never target the acting admin, so nobody can lock themselves out.
  def manage? = super_admin? && !own_account?

  alias_rule :archive?, to: :manage?

  private

  def own_account? = record.id == user.id
end
