require "net/http"

class BookmarksController < ApplicationController
  before_action :set_bookmark, only: %i[ show edit update destroy ]

  # GET /bookmarks or /bookmarks.json
  def index
    @bookmarks = Current.user.bookmarks.all.order(created_at: :desc)
  end

  # GET /bookmarks/1 or /bookmarks/1.json
  def show
  end

  # GET /bookmarks/new
  def new
    @bookmark = Current.user.bookmarks.build
    @bookmark.url = params[:url] if params[:url].present?
  end

  # GET /bookmarks/1/edit
  def edit
  end

  # POST /bookmarks or /bookmarks.json
  def create
    @bookmark = Bookmark.build(user: Current.user)
    @bookmark.attributes = bookmark_params

    respond_to do |format|
      if @bookmark.save
        format.html { redirect_to @bookmark, notice: "Bookmark was successfully created." }
        format.json { render :show, status: :created, location: @bookmark }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @bookmark.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /bookmarks/1 or /bookmarks/1.json
  def update
    respond_to do |format|
      if @bookmark.update(bookmark_params)
        format.html { redirect_to @bookmark, notice: "Bookmark was successfully updated." }
        format.json { render :show, status: :ok, location: @bookmark }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @bookmark.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /bookmarks/1 or /bookmarks/1.json
  def destroy
    @bookmark.destroy!

    respond_to do |format|
      format.html { redirect_to bookmarks_path, status: :see_other, notice: "Bookmark was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  # GET /bookmarks/fetch_remote_bookmark
  def fetch_remote_bookmark
    url = params[:url]
    Rails.logger.debug("Fetching title for URL: #{url}")

    if url.blank?
      render json: { error: "URL is required" }, status: :bad_request
      return
    end

    begin
      response = DownloadWebpageService.new.request_page(url)

      Rails.logger.debug("Response: #{response.code}, Content-Type: #{response.content_type}")

      if response.code != "200"
        render json: { error: "There was a #{response.code} server error fetching page. ", url: url }, status: :unprocessable_content
      elsif !response.content_type&.include?("text/html")
        render json: { error: "This is not an html page.  #{response.content_type}", url: url }, status: :unprocessable_content
      else
        html_document = Nokogiri::HTML(response.body)
        parser = BookmarkHtmlParser.new
        title = parser.extract_og_site_name_from(html_document) || parser.extract_title_from(html_document)
        description = parser.extract_og_description_from(html_document)
        feed_url = parser.extract_rss_feed_from(html_document, url)

        if title.present?
          render json: { title: title, description: description, feed_url: feed_url }
        end
      end
    rescue DownloadWebpageService::DownloadWebpageServiceError => e
      Rails.logger.debug("Error fetching title for URL #{url}: #{e.message}")
      render json: { error: "Error fetching page. Does it exist?", url: url }, status: :not_found
    rescue StandardError => e
      Rails.logger.error("Error fetching title for URL #{url}: #{e.message}")
      render json: { error: "Error fetching title", url: url }, status: :unprocessable_content
    end
  end

  private

    def set_bookmark
      @bookmark = Current.user.bookmarks.find(params.expect(:id))
    end

    def bookmark_params
      params.expect(bookmark: [ :url, :title, :description, :tag_list, :tag_search, tag_ids: [] ])
    end
end
