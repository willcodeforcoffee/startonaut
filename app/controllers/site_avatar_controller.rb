class SiteAvatarController < ApplicationController
  before_action :set_bookmark, only: %i[ show ]

  def show
    @letters = @bookmark.title.first(2).upcase if @bookmark.title.present?
  end

  private

    def set_bookmark
      @bookmark = Current.user.bookmarks.find(params.expect(:id))
    end
end
