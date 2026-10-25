namespace :admin do
  set_admin = lambda do |email_address, admin|
    user = User.find_by(email_address: email_address.to_s.strip.downcase)
    unless user
      puts "Error: No user found with email address '#{email_address}'"
      exit 1
    end

    user.update!(admin: admin)
    puts "#{user.email_address} is #{admin ? 'now' : 'no longer'} an administrator."
  end

  desc "Grant the administrator role to a user, e.g. bin/rails admin:grant[user@example.com]"
  task :grant, [ :email_address ] => :environment do |_task, args|
    set_admin.call(args[:email_address], true)
  end

  desc "List all users with the administrator role"
  task list: :environment do
    admins = User.where(admin: true).order(:email_address)

    if admins.empty?
      puts "No administrators found."
    else
      admins.each { |user| puts user.email_address }
    end
  end

  desc "Revoke the administrator role from a user, e.g. bin/rails admin:revoke[user@example.com]"
  task :revoke, [ :email_address ] => :environment do |_task, args|
    set_admin.call(args[:email_address], false)
  end
end
