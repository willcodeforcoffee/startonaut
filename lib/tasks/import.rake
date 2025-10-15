require "nokogiri"

namespace :import do
  desc "Import bookmarks from Netscape format HTML file"
  task netscape: :environment do
    file_path = Rails.root.join("storage", "bookmarks.html")

    unless File.exist?(file_path)
      puts "Error: bookmarks.html not found in storage directory"
      exit 1
    end

    # Get the first user
    user = User.first
    unless user
      puts "Error: No users found in database. Please create a user first."
      exit 1
    end

    puts "Importing bookmarks for user: #{user.email_address}"

    # Parse the HTML file
    doc = Nokogiri::HTML(File.open(file_path))

    importer = NetscapeBookmarksImport.new(user)
    imported, duplicates, errors = importer.import(doc)

    puts "\n" + "="*50
    puts "Import completed!"
    puts "Imported: #{imported.count} bookmarks"
    puts "Skipped (duplicates): #{duplicates.count} bookmarks"
    puts "Errors: #{errors.count} bookmarks"
  end
end
