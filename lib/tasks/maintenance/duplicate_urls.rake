namespace :maintenance do
  desc "Find and merge duplicate bookmark URLs per user"
  task duplicate_urls: :environment do
    puts "Starting duplicate URL cleanup..."
    puts "=" * 80

    total_duplicates = 0
    total_deleted = 0

    User.find_each do |user|
      puts "\nProcessing user: ID: #{user.id}"

      # Find duplicate URLs for this user
      duplicate_urls = user.bookmarks
        .group(:url)
        .having("COUNT(*) > 1")
        .count
        .keys

      if duplicate_urls.empty?
        puts "  No duplicates found"
        next
      end

      puts "  Found #{duplicate_urls.size} duplicate URL(s)"

      duplicate_urls.each do |url|
        # Get all bookmarks with this URL, ordered by created_at (oldest first)
        bookmarks = user.bookmarks.where(url: url).order(created_at: :asc).to_a

        # Keep the oldest, merge data from newer ones
        keeper = bookmarks.first
        duplicates = bookmarks[1..]

        puts "\n  Processing duplicates for: #{url}"
        puts "  Keeper (oldest): ID=#{keeper.id}, Title='#{keeper.title}', Created=#{keeper.created_at}"

        duplicates.each do |duplicate|
          puts "  Duplicate: ID=#{duplicate.id}, Title='#{duplicate.title}', Created=#{duplicate.created_at}"
          total_duplicates += 1

          # Merge tags (combine unique tags from both)
          original_tags = keeper.tags.pluck(:name)
          duplicate_tags = duplicate.tags.pluck(:name)
          merged_tags = (original_tags + duplicate_tags).uniq

          # Prefer newer bookmark's data for certain fields
          keeper.title = duplicate.title if duplicate.title.present?
          keeper.description = duplicate.description if duplicate.description.present?
          keeper.feed_url = duplicate.feed_url if duplicate.feed_url.present?

          # Merge tags
          keeper.tags = merged_tags.map { |name| user.tags.find_or_create_by(name: name.downcase) }

          # Transfer icons if keeper doesn't have them but duplicate does
          if !keeper.icon.attached? && duplicate.icon.attached?
            keeper.icon.attach(duplicate.icon.blob)
          end

          if !keeper.apple_touch_icon.attached? && duplicate.apple_touch_icon.attached?
            keeper.apple_touch_icon.attach(duplicate.apple_touch_icon.blob)
          end

          # Save the merged keeper
          if keeper.save
            puts "  Merged result: ID=#{keeper.id}, Title='#{keeper.title}', Tags=[#{keeper.tag_list}]"

            # Delete the duplicate
            duplicate.destroy
            total_deleted += 1
            puts "  ✅ Deleted duplicate ID=#{duplicate.id}"
          else
            puts "  ❌ Failed to save merged bookmark: #{keeper.errors.full_messages.join(', ')}"
          end
        end
      end
    end

    puts "\n" + "=" * 80
    puts "Cleanup complete!"
    puts "Total duplicate bookmarks found: #{total_duplicates}"
    puts "Total bookmarks deleted: #{total_deleted}"
  end
end
