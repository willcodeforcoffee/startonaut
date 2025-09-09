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

    # Find all bookmark links (A tags with HREF attribute)
    bookmark_links = doc.css("dt a[href]")

    imported_count = 0
    skipped_count = 0
    error_count = 0

    bookmark_links.each do |link|
      url = link["href"]
      title = link.text.strip
      description = ""
      tags_string = link["tags"] || ""

      # Get description from the DD tag that might follow
      dd_element = link.parent.next_element
      if dd_element&.name == "dd"
        description = dd_element.text.strip
      end

      # Skip if URL already exists for this user
      if user.bookmarks.exists?(url: url.strip.downcase)
        puts "Skipping duplicate URL: #{url}"
        skipped_count += 1
        next
      end

      begin
        # Create the bookmark
        bookmark = user.bookmarks.build(
          url: url,
          title: title.present? ? title : nil,
          description: description.present? ? description : nil
        )

        # Set tags if they exist
        if tags_string.present?
          bookmark.tag_list = tags_string
        end

        if bookmark.save
          puts "Imported: #{title} (#{url})"
          if tags_string.present?
            puts "  Tags: #{tags_string}"
          end
          imported_count += 1
        else
          puts "Error saving bookmark: #{bookmark.errors.full_messages.join(', ')}"
          puts "  URL: #{url}"
          error_count += 1
        end

      rescue StandardError => e
        puts "Error processing bookmark: #{e.message}"
        puts "  URL: #{url}"
        error_count += 1
      end
    end

    puts "\n" + "="*50
    puts "Import completed!"
    puts "Imported: #{imported_count} bookmarks"
    puts "Skipped (duplicates): #{skipped_count} bookmarks"
    puts "Errors: #{error_count} bookmarks"
    puts "Total processed: #{bookmark_links.count} bookmarks"
  end
end
