module FeedArticlesHelper
  # Turbo Frame id for the page of articles that follows the given cursor
  def feed_page_frame_id(cursor)
    _, id = FeedArticle.parse_cursor(cursor)
    id ? "feed_page_after_#{id}" : "feed_page_first"
  end
end
