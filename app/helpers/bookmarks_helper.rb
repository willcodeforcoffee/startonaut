module BookmarksHelper
  # Format a date or datetime in YYYY-MM-DD format
  def format_date_short(date)
    return nil unless date
    date.strftime("%Y-%m-%d")
  end

  def favicon_image_tag(bookmark, options = {})
    image_tag site_bookmark_favicon_index_path(site_bookmark_id: bookmark.id), options.merge(alt: "Site Favicon image for #{bookmark.title}")
  end
end
