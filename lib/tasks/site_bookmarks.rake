namespace :site_bookmarks do
  desc "Copy bookmarks rows into site_bookmarks"
  task copy_from_bookmarks: :environment do
    copied = 0
    updated = 0

    Bookmark.find_each do |bookmark|
      site_bookmark = SiteBookmark.find_or_initialize_by(id: bookmark.id)
      site_bookmark.assign_attributes(
        user_id: bookmark.user_id,
        url: bookmark.url,
        title: bookmark.title,
        description: bookmark.description,
        feed_url: bookmark.feed_url,
        created_at: bookmark.created_at,
        updated_at: bookmark.updated_at
      )

      if site_bookmark.new_record?
        site_bookmark.id = bookmark.id
        copied += 1
      else
        updated += 1
      end

      site_bookmark.save!
    end

    copied_tag_links = copy_tag_links

    puts "Copied #{copied} bookmarks"
    puts "Updated #{updated} existing site_bookmarks"
    puts "Copied #{copied_tag_links} tag links"
  end

  def copy_tag_links
    connection = ActiveRecord::Base.connection
    return 0 unless connection.data_source_exists?("bookmarks_tags")
    return 0 unless connection.data_source_exists?("site_bookmarks_tags")

    copied_tag_links = 0

    rows = connection.exec_query("SELECT bookmark_id, tag_id FROM bookmarks_tags")

    rows.each do |row|
      next unless SiteBookmark.exists?(id: row["bookmark_id"])

      bookmark_id = connection.quote(row["bookmark_id"])
      tag_id = connection.quote(row["tag_id"])

      existing = connection.exec_query(
        "SELECT 1 FROM site_bookmarks_tags WHERE site_bookmark_id = #{bookmark_id} AND tag_id = #{tag_id} LIMIT 1"
      )

      next if existing.any?

      connection.execute(
        "INSERT INTO site_bookmarks_tags (site_bookmark_id, tag_id) VALUES (#{bookmark_id}, #{tag_id})"
      )
      copied_tag_links += 1
    end

    copied_tag_links
  end
end
