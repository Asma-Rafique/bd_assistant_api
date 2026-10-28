class AddInvitationsToUsers < ActiveRecord::Migration[8.1]
  # A concurrent index can't be built inside a transaction.
  disable_ddl_transaction!

  def change
    # Safe: new nullable columns and a dropped NOT NULL don't rewrite the table.
    safety_assured do
      change_table :users, bulk: true do |t|
        # An invited user has no password until they accept.
        t.change_null :password_digest, true
        t.datetime :invitation_sent_at
        t.datetime :invitation_accepted_at
      end
    end

    add_reference :users, :invited_by, index: { algorithm: :concurrently }
    # Added without checking existing rows, so it takes no long lock; then checked separately.
    add_foreign_key :users, :users, column: :invited_by_id, on_delete: :nullify, validate: false
    validate_foreign_key :users, column: :invited_by_id
  end
end
