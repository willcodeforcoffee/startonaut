namespace :bookmarks do
  desc "Scan bookmarks with no feed_url for an RSS/Atom feed and save it if found"
  task discover_feed_urls: :environment do
    bookmarks = Bookmark.where(feed_url: nil)
    bookmarks = bookmarks.limit(ENV["LIMIT"].to_i) if ENV["LIMIT"].present?
    total = bookmarks.count

    puts "Found #{total} bookmarks with no feed_url"

    found_count = 0
    error_count = 0
    not_found_count = 0

    bookmarks.find_each.with_index do |bookmark, index|
      puts "[#{index + 1}/#{total}] Scanning: #{bookmark.url}"

      begin
        response = DownloadWebpageService.new.request_page(bookmark.url)

        if response.nil? || response.code != "200"
          puts "  ⚠️  Skipped - Could not fetch page (#{response&.code || 'no response'})"
          not_found_count += 1
          next
        end

        unless response.content_type&.include?("text/html")
          puts "  ⚠️  Skipped - Not an HTML page (#{response.content_type})"
          not_found_count += 1
          next
        end

        html_document = Nokogiri::HTML(response.body)
        feed_url = BookmarkHtmlParser.new.extract_rss_feed_from(html_document, bookmark.url)

        if feed_url.present?
          bookmark.feed_url = feed_url
          if bookmark.save
            puts "  ✅ Found feed: #{feed_url}"
            found_count += 1
          else
            puts "  ❌ Save failed: #{bookmark.errors.full_messages.join(', ')}"
            error_count += 1
          end
        else
          puts "  ➖ No feed found"
          not_found_count += 1
        end

      rescue DownloadWebpageService::DownloadWebpageServiceError => e
        puts "  ❌ Download error: #{e.message}"
        error_count += 1
      rescue StandardError => e
        puts "  ❌ Unexpected error: #{e.message}"
        error_count += 1
      end

      sleep(0.5) if index < total - 1
    end

    puts "\n" + "=" * 60
    puts "Feed discovery completed!"
    puts "Total bookmarks scanned: #{total}"
    puts "Feeds found: #{found_count}"
    puts "No feed found: #{not_found_count}"
    puts "Errors: #{error_count}"
    puts "=" * 60
  end
end
