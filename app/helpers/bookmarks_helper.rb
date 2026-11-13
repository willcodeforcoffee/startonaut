module BookmarksHelper
  # Format a date or datetime in YYYY-MM-DD format
  def format_date_short(date)
    return nil unless date
    date.strftime("%Y-%m-%d")
  end

  # Format a date or datetime in YYYY-MM-DD HH:MM format
  def format_datetime_short(datetime)
    return nil unless datetime
    datetime.strftime("%Y-%m-%d %H:%M")
  end

  # Data attributes that record a click (see bookmark_click_controller.js) when a bookmark link is opened
  def bookmark_click_data(bookmark)
    {
      controller: "bookmark-click",
      bookmark_click_url_value: bookmark_clicks_path(bookmark),
      action: "click->bookmark-click#track auxclick->bookmark-click#track"
    }
  end

  def favicon_image_tag(bookmark, options = {})
    image_tag bookmark_favicon_index_path(bookmark_id: bookmark.id), options.merge(alt: "Site Favicon image for #{bookmark.title}")
  end
end
