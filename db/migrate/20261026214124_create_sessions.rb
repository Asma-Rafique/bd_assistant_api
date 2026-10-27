class CreateSessions < ActiveRecord::Migration[8.1]
  # db/migrate/..._create_sessions.rb
  def change
    create_table :sessions do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.string :token_digest, null: false, index: { unique: true }
      t.string :ip_address
      t.string :user_agent
      t.datetime :expires_at, null: false, index: true
      t.datetime :last_active_at, null: false, index: true
      t.timestamps
    end
  end
end
