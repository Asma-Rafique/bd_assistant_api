class CreateUsers < ActiveRecord::Migration[8.1]
  # db/migrate/..._create_users.rb
  def change
    create_table :users do |t|
      t.string :email, null: false, index: { unique: true }
      t.string :password_digest, null: false
      t.string :first_name
      t.string :last_name
      t.integer :role, null: false, default: 0
      t.datetime :archived_at
      t.datetime :last_sign_in_at
      t.timestamps
    end
  end
end
