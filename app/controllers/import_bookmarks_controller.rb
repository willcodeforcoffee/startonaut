class ImportBookmarksController < ApplicationController
  before_action :require_authentication

  # GET /import_bookmarks/new
  def new
  end

  # POST /import_bookmarks
  def create
    file = params[:file]

    if file.blank?
      flash[:alert] = "Please select a file to import."
      return render :new
    end

    unless file.content_type.in?([ "text/html", "text/plain" ])
      flash[:alert] = "Invalid file type. Please upload an HTML file."
      return render :new
    end

    begin
      html_content = file.read
      html_document = Nokogiri::HTML(html_content)

      importer = NetscapeBookmarksImport.new(Current.user)
      imported, duplicates, errors = importer.import(html_document)

      messages = []
      messages << "Successfully imported #{imported.size} bookmarks." if imported.any?
      messages << "#{duplicates.size} duplicates skipped." if duplicates.any?
      messages << "#{errors.size} errors occurred." if errors.any?

      flash[:notice] = messages.join(" ")
      redirect_to bookmarks_path
    rescue StandardError => e
      flash[:alert] = "Error importing bookmarks: #{e.message}"
      render :new
    end
  end

  private

  def require_authentication
    redirect_to new_session_path, alert: "Please sign in to import bookmarks" unless authenticated?
  end
end
