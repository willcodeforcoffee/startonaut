class BookmarkClicksController < ApplicationController
  # POST /bookmarks/1/clicks
  def create
    bookmark = Current.user.bookmarks.find(params[:bookmark_id])
    bookmark.clicks.create!
    head :no_content
  end
end
