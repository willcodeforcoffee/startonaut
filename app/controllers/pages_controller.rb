class PagesController < ApplicationController
  def index
    bookmarks = Current.user.bookmarks.tagged_with_all(selected_tag_names).order(created_at: :desc)
    @read_later_bookmarks = bookmarks.tagged_with_all(Tag::READ_LATER).to_a
    @today_bookmarks = bookmarks.tagged_with_all(Tag.todays_name).to_a

    @bookmarks = params[:q].present? ? bookmarks.search_by_title(params[:q]) : bookmarks

    # Tag counts match the current tag filter and search
    tags = tags_with_bookmark_counts(@bookmarks).to_a
    @tags_by_letter = group_tags_by_letter(tags)
    @favorite_tags = tags.select(&:favorite?)

    # Exclude "Read Later" and "Today" bookmarks from the main list
    @bookmarks = @bookmarks.to_a - @read_later_bookmarks - @today_bookmarks
  end

  # POST /pages/search
  def search
    redirect_to pages_path(q: params[:q].presence, tags: selected_tag_names.join(",").presence)
  end
end
