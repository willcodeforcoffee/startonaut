namespace :site_bookmarks do
  desc "Update all bookmark metadata (title, description, feed_url) from their URLs"
  task update_bookmarks: :environment do
    puts "Starting bookmark metadata update..."

    total_bookmarks = SiteBookmark.count
    updated_count = 0
    error_count = 0
    skipped_count = 0

    puts "Found #{total_bookmarks} bookmarks to process"

    SiteBookmark.find_each.with_index do |bookmark, index|
      puts "[#{index + 1}/#{total_bookmarks}] Processing: #{bookmark.url}"

      begin
        # Download the webpage
        service = DownloadWebpageService.new
        response = service.request_page(bookmark.url)

        if response.nil? || response.code != "200"
          puts "  ⚠️  Skipped - Could not fetch page (#{response&.code || 'no response'})"
          skipped_count += 1
          next
        end

        unless response.content_type&.include?("text/html")
          puts "  ⚠️  Skipped - Not an HTML page (#{response.content_type})"
          skipped_count += 1
          next
        end

        # Parse the HTML and extract metadata
        html_document = Nokogiri::HTML(response.body)
        parser = BookmarkHtmlParser.new

        old_title = bookmark.title
        old_description = bookmark.description
        old_feed_url = bookmark.feed_url

        # Extract new metadata using parser methods
        new_title = parser.extract_og_site_name_from(html_document) || parser.extract_title_from(html_document)
        new_description = parser.extract_og_description_from(html_document)
        new_feed_url = parser.extract_rss_feed_from(html_document, bookmark.url)

        # Update bookmark attributes
        bookmark.title = new_title if new_title.present?
        bookmark.description = new_description if new_description.present?
        bookmark.feed_url = new_feed_url if new_feed_url.present?

        DownloadFaviconsJob.new.perform(bookmark.id)

        # Save changes if any attributes were updated
        if bookmark.changed?
          if bookmark.save
            changes = []
            changes << "title: '#{old_title}' → '#{bookmark.title}'" if bookmark.title != old_title
            changes << "description: '#{old_description}' → '#{bookmark.description}'" if bookmark.description != old_description
            changes << "feed_url: '#{old_feed_url}' → '#{bookmark.feed_url}'" if bookmark.feed_url != old_feed_url

            puts "  ✅ Updated: #{changes.join(', ')}"
            updated_count += 1
          else
            puts "  ❌ Save failed: #{bookmark.errors.full_messages.join(', ')}"
            error_count += 1
          end
        else
          puts "  ➖ No changes needed"
          skipped_count += 1
        end

      rescue DownloadWebpageService::DownloadWebpageServiceError => e
        puts "  ❌ Download error: #{e.message}"
        error_count += 1
      rescue StandardError => e
        puts "  ❌ Unexpected error: #{e.message}"
        error_count += 1
      end

      # Add a small delay to be respectful to servers
      sleep(0.5) if index < total_bookmarks - 1
    end

    puts "\n" + "="*60
    puts "Bookmark metadata update completed!"
    puts "Total bookmarks processed: #{total_bookmarks}"
    puts "Successfully updated: #{updated_count}"
    puts "Skipped (no changes/errors): #{skipped_count}"
    puts "Errors: #{error_count}"
    puts "="*60
  end
end
