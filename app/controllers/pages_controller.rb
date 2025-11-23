class PagesController < ApplicationController
  def index
    @bookmarks = Current.user.bookmarks.all.order(created_at: :desc)
    @tags_by_letter = Current.user.tags.order(:name).group_by { |tag| tag.name.first.upcase }
    @favorite_tags = Current.user.tags.favorites.order(:name)

    @read_later_bookmarks = Current.user.tags.read_later.first.bookmarks.order(created_at: :desc)
    @today_bookmarks = Current.user.tags.today_tag.first&.bookmarks&.order(created_at: :desc) || []

    # Exclude "Read Later" bookmarks from the main list
    @bookmarks = @bookmarks - @read_later_bookmarks if @read_later_bookmarks.any?
  end
end
