# Safe to run any number of times: every record is found or created, never
# duplicated. Run with bin/rails db:seed (bin/setup runs it on a new database).

# The first super admin, in every environment. The password comes from the
# environment, never from this file, because seeds are committed to git:
#   SUPER_ADMIN_EMAIL=you@example.com SUPER_ADMIN_PASSWORD='S3cure!pass' bin/rails db:seed
email = ENV.fetch("SUPER_ADMIN_EMAIL", nil)
password = ENV.fetch("SUPER_ADMIN_PASSWORD", nil)

if email.present? && password.present?
  User.find_or_create_by!(email:) do |user|
    user.role = :super_admin
    user.password = password
  end
  puts "Super admin ready: #{email}"
else
  puts "Skipped the super admin: set SUPER_ADMIN_EMAIL and SUPER_ADMIN_PASSWORD."
end

# Demo accounts for trying the app locally. Never created in production.
if Rails.env.development?
  demo_password = "Passw0rd!"

  admin = User.find_or_create_by!(email: "admin@example.com") do |user|
    user.assign_attributes(role: :super_admin, first_name: "Ana", last_name: "Diaz", password: demo_password)
  end

  [%w[sam@example.com Sam Lee], %w[member@example.com Mia Khan]].each do |user_email, first_name, last_name|
    User.find_or_create_by!(email: user_email) do |user|
      user.assign_attributes(role: :team_member, first_name:, last_name:, password: demo_password)
    end
  end

  User.find_or_create_by!(email: "invited@example.com") do |user|
    user.assign_attributes(role: :team_member, invited_by: admin, invitation_sent_at: Time.current)
  end

  puts "Demo accounts ready: admin@example.com, sam@example.com, member@example.com " \
       "(password #{demo_password}), and a pending invitation for invited@example.com."
end
