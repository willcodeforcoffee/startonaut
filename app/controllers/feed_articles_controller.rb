class FeedArticlesController < ApplicationController
  # GET /feed_articles
  def index
    bookmarks = Current.user.bookmarks.tagged_with_all(selected_tag_names)

    # Lazy-loaded pages only need the articles, not the tags sidebar
    @tags_by_letter = group_tags_by_letter(tags_with_bookmark_counts(bookmarks)) unless turbo_frame_request?

    @feed_articles, @next_cursor = FeedArticle
      .where(bookmark_id: bookmarks.select(:id))
      .includes(:bookmark)
      .recent_first
      .page_before(params[:before])
  end
end
