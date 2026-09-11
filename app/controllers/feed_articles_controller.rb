class FeedArticlesController < ApplicationController
  # GET /feed_articles
  def index
    @feed_articles = FeedArticle
      .joins(:bookmark)
      .where(bookmarks: { user_id: Current.user.id })
      .includes(:bookmark)
      .recent_first
  end
end
