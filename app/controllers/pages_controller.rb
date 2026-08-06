class PagesController < ApplicationController
  def index
    if params[:q].present?
      @bookmarks = Current.user.bookmarks.search_by_title(params[:q]).order(created_at: :desc)
    else
      @bookmarks = Current.user.bookmarks.all.order(created_at: :desc)
    end
    @tags_by_letter = Current.user.tags.order(:name).group_by { |tag| tag.name.first.upcase }
    @favorite_tags = Current.user.tags.favorites.order(:name)

    @read_later_bookmarks = Current.user.tags.read_later.first.bookmarks.order(created_at: :desc)
    @today_bookmarks = Current.user.tags.today_tag.first&.bookmarks&.order(created_at: :desc) || []

    # Exclude "Read Later" and "Today" bookmarks from the main list
    @bookmarks = @bookmarks - @read_later_bookmarks if @read_later_bookmarks.any?
    @bookmarks = @bookmarks - @today_bookmarks if @today_bookmarks.any?
  end

  # POST /pages/search
  def search
    redirect_to pages_path(q: params[:q])
  end
end
