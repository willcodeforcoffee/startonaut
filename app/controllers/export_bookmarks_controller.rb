class ExportBookmarksController < ApplicationController
  def index
  end

  def show
    @bookmarks = Current.user.bookmarks.includes(:tags).order(created_at: :desc)
    render layout: false
  end
end
