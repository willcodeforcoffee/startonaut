class PagesController < ApplicationController
  def index
    @bookmarks = Current.user.bookmarks.all.order(created_at: :desc)
    @tags_by_letter = Current.user.tags.order(:name).group_by { |tag| tag.name.first.upcase }
  end
end
