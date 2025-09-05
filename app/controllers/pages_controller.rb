class PagesController < ApplicationController
  def index
    @bookmarks = Current.user.bookmarks.all
    @tags = Current.user.tags.all
  end
end
