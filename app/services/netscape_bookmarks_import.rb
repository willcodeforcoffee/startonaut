class NetscapeBookmarksImport
  def initialize(user)
    @user = user
  end

  def import(html_document)
    # Find all bookmark links (A tags with HREF attribute)
    bookmark_links = html_document.css("dt a[href]")

    imported = []
    duplicates = []
    errors = []

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
      if @user.site_bookmarks.exists?(url: url.strip.downcase)
        duplicates << url
        next
      end

      begin
        # Create the bookmark
        bookmark = @user.site_bookmarks.build(
          url: url,
          title: title.present? ? title : nil,
          description: description.present? ? description : nil
        )

        # Set tags if they exist
        if tags_string.present?
          bookmark.tag_list = tags_string
        end

        if bookmark.save
          imported << "#{title} (#{url})"
        else
          errors << "Error saving bookmark: #{bookmark.errors.full_messages.join(', ')} for URL: #{url}"
        end

      rescue StandardError => e
        errors << "Error processing bookmark: #{e.message} for URL: #{url}"
      end
    end

    return imported, duplicates, errors
  end
end
