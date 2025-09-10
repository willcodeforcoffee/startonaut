class BookmarksFaviconProxyController < ApplicationController
  include ActionController::Live

  def index
    @bookmark = Current.user.bookmarks.find(params[:bookmark_id])
    head :not_found unless @bookmark.present?

    logger.debug("Serving favicon for bookmark #{@bookmark.id}:#{@bookmark.title}")

    if @bookmark.icon.attached?
      logger.debug("Serving icon for bookmark #{@bookmark.id}:#{@bookmark.title}")
      return send_svg(@bookmark.icon_blob.download) if @bookmark.icon.content_type == "image/svg+xml"
      stream_image_blob(@bookmark.icon_blob)

    elsif @bookmark.apple_touch_icon.attached?
      logger.debug("Serving Apple icon for bookmark #{@bookmark.id}:#{@bookmark.title}")
      stream_image_blob(@bookmark.apple_touch_icon_blob)

    else
      logger.debug("No icon attached for bookmark #{@bookmark.id}:#{@bookmark.title}, generating two-letter avatar")
      send_two_letter_avatar
    end
  end

  private

    def stream_image_blob(blob)
      http_cache_forever public: true do
        response.headers["Accept-Ranges"] = "bytes"
        response.headers["Content-Length"] = blob.byte_size.to_s

        send_stream(
          filename: blob.filename.sanitized,
          disposition: blob.forced_disposition_for_serving || "inline",
          type: blob.content_type_for_serving) do |stream|
            blob.download do |chunk|
              stream.write chunk
            end
          rescue ActiveStorage::FileNotFoundError
            logger.error("Blob not found: #{blob.id} for bookmark #{@bookmark.id}:#{@bookmark.title}")
            # Status and caching headers are already set, but not committed.
            expires_now
            head :not_found
          rescue
            # Status and caching headers are already set, but not committed.
            # Change the status to 500 manually.
            expires_now
            head :internal_server_error
            raise
          end
      end
    end

    def send_two_letter_avatar
      content = <<~SVG
        <?xml version="1.0" encoding="UTF-8"?>
        <svg version="1.1" xmlns="http://www.w3.org/2000/svg" width="50" height="50" viewBox="0 0 50 50">
          <rect width="100%" height="100%" fill="#011627"/>
          <text fill="#41ead4" font-family="PT Sans,Helvetica,Arial,sans-serif" font-size="26" font-weight="500" x="50%" y="55%" dominant-baseline="middle" text-anchor="middle">
            #{@bookmark.title.first(2).upcase}
          </text>
        </svg>
      SVG

      send_svg(content)
    end

    def send_svg(content)
      logger.debug("Serving SVG content for bookmark #{@bookmark.id}:\n\t#{content}")
      # http_cache_forever public: true do
      render xml: content, content_type: "image/svg+xml", disposition: "inline"
      # end
    end
end
