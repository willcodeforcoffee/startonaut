class PagesController < ApplicationController
  def index
    @bookmarks = Current.user.site_bookmarks.all.order(created_at: :desc)
    @tags_by_letter = Current.user.tags.order(:name).group_by { |tag| tag.name.first.upcase }
    @favorite_tags = Current.user.tags.favorites.order(:name)

    @read_later_bookmarks = Current.user.tags.read_later.first.site_bookmarks.order(created_at: :desc)
    @today_bookmarks = Current.user.tags.today_tag.first&.site_bookmarks&.order(created_at: :desc) || []

    # Exclude "Read Later" and "Today" bookmarks from the main list
    @bookmarks = @bookmarks - @read_later_bookmarks if @read_later_bookmarks.any?
    @bookmarks = @bookmarks - @today_bookmarks if @today_bookmarks.any?
  end
end
