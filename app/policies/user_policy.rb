class UserPolicy < ApplicationPolicy
  # The users a caller may see at all: super admins see everyone, team
  # members only themselves.
  relation_scope do |relation|
    super_admin? ? relation : relation.where(id: user.id)
  end

  def index? = super_admin?
  def show? = super_admin? || own_account?
  def update? = super_admin? || own_account?
  def invite? = super_admin?

  # Admin actions never target the acting admin, so nobody can lock themselves out.
  def manage? = super_admin? && !own_account?
  # Only an invitation that hasn't been accepted can be resent or cancelled.
  def manage_invitation? = manage? && record.invitation_pending?

  alias_rule :archive?, to: :manage?
  alias_rule :resend_invitation?, :destroy_invitation?, to: :manage_invitation?

  private

  def own_account? = record.id == user.id
end
