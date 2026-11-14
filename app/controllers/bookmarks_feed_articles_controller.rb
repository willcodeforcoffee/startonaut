class BookmarksFeedArticlesController < ApplicationController
  before_action :set_bookmark

  # GET /bookmarks/1/feed_articles
  def index
    @feed_articles, @next_cursor = @bookmark.feed_articles.recent_first.page_before(params[:before])
  end

  private

    def set_bookmark
      @bookmark = Current.user.bookmarks.find(params.expect(:bookmark_id))
    end
end
