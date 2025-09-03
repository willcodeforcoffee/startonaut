module BookmarksHelper
  # Format a date or datetime in YYYY-MM-DD format
  def format_date_short(date)
    return nil unless date
    date.strftime("%Y-%m-%d")
  end

  def favicon_image_tag(bookmark)
    return image_tag rails_storage_proxy_path(bookmark.favicon), class: "inline object-contain w-[1rem]" if bookmark.favicon.attached?
    return image_tag rails_storage_proxy_path(bookmark.icon), class: "inline object-contain w-[1rem]" if bookmark.icon.attached?
    return image_tag rails_storage_proxy_path(bookmark.apple_touch_icon), class: "inline object-contain w-[1rem]" if bookmark.apple_touch_icon.attached?

    ""
  end
end
