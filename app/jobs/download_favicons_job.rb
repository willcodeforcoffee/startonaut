require "net/http"

class DownloadFaviconsJob < ApplicationJob
  queue_as :default

  # Retry logic for network failures
  retry_on Net::ReadTimeout, wait: :exponentially_longer, attempts: 3
  retry_on Net::OpenTimeout, wait: :exponentially_longer, attempts: 3
  retry_on SocketError, wait: :exponentially_longer, attempts: 2

  # Don't retry for these errors
  discard_on ActiveRecord::RecordNotFound

  def perform(bookmark_id)
    # Load the @bookmark and abort if not found
    @bookmark = Bookmark.find(bookmark_id)

    Rails.logger.info("Starting favicon download for @bookmark #{@bookmark.id}: #{@bookmark.url}")

    # Fetch the webpage HTML
    html_response = DownloadWebpageService.new.request_page(@bookmark.url)
    Rails.logger.debug("Fetched HTML for #{@bookmark.url} with response code #{html_response&.code}")
    return unless html_response&.code == "200"

    # Parse the HTML to find icon links
    doc = Nokogiri::HTML(html_response.body)
    base_uri = URI.parse(@bookmark.url)

    # Download icons based on <link> elements
    download_icon_from_links(@bookmark, doc, base_uri)
    download_apple_touch_icon_from_links(@bookmark, doc, base_uri)

    Rails.logger.info("Completed favicon download for @bookmark #{@bookmark.id}")

  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.warn("@bookmark with ID #{bookmark_id} not found, aborting favicon download")
    raise e # This will be discarded due to discard_on

  rescue StandardError => e
    Rails.logger.error("Error downloading favicons for @bookmark #{bookmark_id}: #{e.message}")
    raise e # This will trigger retries for retryable errors
  rescue => e
    Rails.logger.error("Unexpected error: #{e}")
  end

  private

  def download_icon_from_links(bookmark, doc, base_uri)
    # Look for <link rel="icon"> elements
    icon_links = doc.css('link[rel*="icon"]').reject do |link|
      rel = link["rel"]&.downcase
      rel&.include?("apple") # Exclude apple-touch-icon links
    end

    # Prefer PNG over ICO, and larger sizes
    icon_links = prioritize_icon_links(icon_links)

    icon_links.each do |link|
      href = link["href"]
      next if href.blank?
      Rails.logger.debug("Found icon link: #{href}")

      icon_url = resolve_url(href, base_uri)
      next unless icon_url

      if download_and_attach_icon(bookmark, icon_url, :icon)
        Rails.logger.info("Successfully downloaded icon from #{icon_url}")
        break
      end
    end
  end

  def download_apple_touch_icon_from_links(bookmark, doc, base_uri)
    # Look for <link rel="apple-touch-icon"> elements
    apple_icon_links = doc.css('link[rel*="apple-touch-icon"]')

    # Prefer larger sizes
    apple_icon_links = prioritize_apple_icon_links(apple_icon_links)

    apple_icon_links.each do |link|
      href = link["href"]
      next if href.blank?
      Rails.logger.debug("Found apple-touch-icon link: #{href}")

      icon_url = resolve_url(href, base_uri)
      next unless icon_url

      if download_and_attach_icon(bookmark, icon_url, :apple_touch_icon)
        Rails.logger.info("Successfully downloaded apple touch icon from #{icon_url}")
        break
      end
    end
  end

  def prioritize_icon_links(links)
    # Sort by preference: PNG > SVG > ICO, and larger sizes first
    links.sort_by do |link|
      href = link["href"]&.downcase || ""
      sizes = link["sizes"]
      type = link["type"]&.downcase

      # Calculate priority score (lower is better)
      format_score = case
      when type&.include?("svg") || href.include?(".svg") then 1
      when type&.include?("png") || href.include?(".png") then 2
      when type&.include?("jpg") || href.include?(".jpg") then 3
      when type&.include?("ico") || href.include?(".ico") then 4
      else 5
      end

      # Extract size (prefer larger icons)
      size_score = if sizes && sizes.match(/(\d+)x\d+/)
        -$1.to_i # Negative to sort larger first
      else
        0
      end

      [ format_score, size_score ]
    end
  end

  def prioritize_apple_icon_links(links)
    # Sort by size (prefer larger icons)
    links.sort_by do |link|
      sizes = link["sizes"]
      if sizes && sizes.match(/(\d+)x\d+/)
        -$1.to_i # Negative to sort larger first
      else
        0
      end
    end
  end

  def resolve_url(href, base_uri)
    # Handle relative URLs
    if href.start_with?("//")
      # Protocol-relative URL
      "#{base_uri.scheme}:#{href}"
    elsif href.start_with?("/")
      # Absolute path
      "#{base_uri.scheme}://#{base_uri.host}#{base_uri.port && base_uri.port != base_uri.default_port ? ":#{base_uri.port}" : ''}#{href}"
    elsif href.start_with?("http")
      # Already absolute URL
      href
    else
      # Relative path
      base_url = "#{base_uri.scheme}://#{base_uri.host}#{base_uri.port && base_uri.port != base_uri.default_port ? ":#{base_uri.port}" : ''}"
      path = File.dirname(base_uri.path)
      path = "/" if path == "."
      "#{base_url}#{path}/#{href}"
    end
  rescue StandardError => e
    Rails.logger.error("Failed to resolve URL #{href}: #{e.message}")
    nil
  end

  def download_and_attach_icon(bookmark, icon_url, attachment_name)
    response = DownloadWebpageService.new.request_page(icon_url)
    return false unless response && response.code == "200"

    # Validate content type
    content_type = response.content_type
    return false unless valid_image_content_type?(content_type)

    # Validate file size (reasonable limits)
    body_size = response.body.bytesize
    max_size = attachment_name == :apple_touch_icon ? 1.megabyte : 512.kilobytes
    return false if body_size > max_size

    # Create a temporary file
    temp_file = Tempfile.new([ "icon", file_extension_for_content_type(content_type) ])
    temp_file.binmode
    temp_file.write(response.body)
    temp_file.rewind

    # Generate filename
    filename = File.basename(URI.parse(icon_url).path)
    filename = "#{attachment_name}#{file_extension_for_content_type(content_type)}" if filename.blank? || !filename.include?(".")

    # Attach the file
    bookmark.public_send(attachment_name).attach(
      io: temp_file,
      filename: filename,
      content_type: content_type
    )

    temp_file.close
    temp_file.unlink

    true

  rescue StandardError => e
    Rails.logger.error("Failed to download icon from #{icon_url}: #{e.message}")
    temp_file&.close
    temp_file&.unlink
    false
  end

  def valid_image_content_type?(content_type)
    return false if content_type.blank?

    valid_types = %w[
      image/png
      image/jpg
      image/jpeg
      image/gif
      image/svg+xml
      image/x-icon
      image/vnd.microsoft.icon
      image/ico
    ]

    valid_types.any? { |type| content_type.include?(type) }
  end

  def file_extension_for_content_type(content_type)
    case content_type
    when /png/ then ".png"
    when /jpe?g/ then ".jpg"
    when /gif/ then ".gif"
    when /svg/ then ".svg"
    when /ico/ then ".ico"
    else ".png"
    end
  end
end
