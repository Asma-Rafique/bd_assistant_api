class AddOtpEnabledToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :otp_enabled, :boolean, null: false, default: false
  end
end
