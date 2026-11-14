class FeedArticlesController < ApplicationController
  # GET /feed_articles
  def index
    @feed_articles, @next_cursor = FeedArticle
      .joins(:bookmark)
      .where(bookmarks: { user_id: Current.user.id })
      .includes(:bookmark)
      .recent_first
      .page_before(params[:before])
  end
end
