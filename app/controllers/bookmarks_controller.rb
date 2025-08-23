require "net/http"

class BookmarksController < ApplicationController
  before_action :set_bookmark, only: %i[ show edit update destroy ]

  # GET /bookmarks or /bookmarks.json
  def index
    @bookmarks = Current.user.bookmarks.all
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
      response = request_page(url)
      title = extract_title_from_url(response)
      Rails.logger.debug("Fetched title: #{title || 'nil'}")

      if title.present?
        render json: { title: title }
        return
      end

      render json: { error: "Title not found", url: url }, status: :not_found
    rescue StandardError => e
      Rails.logger.error("Error fetching title for URL #{url}: #{e.message}")
      render json: { error: "Error fetching title", url: url }, status: :unprocessable_content
    end
  end

  private

    def extract_title_from_url(response)
      if response.code == "200" && response.content_type&.include?("text/html")
        doc = Nokogiri::HTML(response.body)
        title_element = doc.at_css("title")
        return title_element&.text&.strip
      end

      nil
    end

    def request_page(url)
      uri = URI.parse(url)
      return nil unless %w[http https].include?(uri.scheme)

      # Set timeout and user agent
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = 5
      http.read_timeout = 10

      req = Net::HTTP::Get.new(uri.request_uri)
      req["User-Agent"] = "Mozilla/5.0 (Startonaut.com Page information preload)"

      http.request(req)
    end

    def set_bookmark
      @bookmark = Current.user.bookmarks.find(params.expect(:id))
    end

    def bookmark_params
      params.expect(bookmark: [ :url, :title, :description, :tag_list, :tag_search, tag_ids: [] ])
    end
end
