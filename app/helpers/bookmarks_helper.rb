module BookmarksHelper
  # Format a date or datetime in YYYY-MM-DD format
  def format_date_short(date)
    return nil unless date
    date.strftime("%Y-%m-%d")
  end

  def favicon_image_tag(bookmark, options = {})
    return image_tag rails_storage_proxy_path(bookmark.icon), options.merge(alt: "Icon image for #{bookmark.title}") if bookmark.icon.attached?
    return image_tag rails_storage_proxy_path(bookmark.apple_touch_icon), options.merge(alt: "Apple Touch Icon image for #{bookmark.title}") if bookmark.apple_touch_icon.attached?

    image_tag site_avatar_path(id: bookmark.id, format: :svg), options.merge(alt: "Site Avatar image for #{bookmark.title}")
  end
end
