class BookmarkHtmlParser
  def extract_og_site_name_from(html_document)
    og_site_name = html_document.at('meta[property="og:site_name"]')&.[]("content")
    og_site_name&.strip
  end

  def extract_og_description_from(html_document)
    og_description = html_document.at('meta[property="og:description"]')&.[]("content")
    og_description&.strip
  end

  def extract_title_from(html_document)
    title_element = html_document.at_css("title")
    title_element&.text&.strip
  end

  def extract_rss_feed_from(html_document, base_url)
    # Look for RSS/Atom feed links in order of preference
    feed_selectors = [
      'link[type="application/rss+xml"]',
      'link[type="application/atom+xml"]',
      'link[type="application/feed+xml"]',
      'link[rel="alternate"][type="application/rss+xml"]',
      'link[rel="alternate"][type="application/atom+xml"]',
      'link[rel="alternate"][type="application/feed+xml"]'
    ]

    feed_selectors.each do |selector|
      feed_link = html_document.at_css(selector)
      if feed_link
        href = feed_link["href"]
        next if href.blank?

        # Convert relative URLs to absolute URLs
        feed_url = resolve_feed_url(href, base_url)
        return feed_url if feed_url
      end
    end

    # If no explicit feed links found, try common feed paths
    try_common_feed_paths(base_url)
  end

  private

  def resolve_feed_url(href, base_url)
    return href if href.start_with?("http")

    base_uri = URI.parse(base_url)

    if href.start_with?("//")
      # Protocol-relative URL
      "#{base_uri.scheme}:#{href}"
    elsif href.start_with?("/")
      # Absolute path
      "#{base_uri.scheme}://#{base_uri.host}#{base_uri.port != base_uri.default_port ? ":#{base_uri.port}" : ''}#{href}"
    else
      # Relative path
      base_path = File.dirname(base_uri.path)
      base_path = "/" if base_path == "."
      "#{base_uri.scheme}://#{base_uri.host}#{base_uri.port != base_uri.default_port ? ":#{base_uri.port}" : ''}#{base_path}/#{href}"
    end
  rescue StandardError => e
    Rails.logger.debug("Error resolving feed URL #{href}: #{e.message}")
    nil
  end

  def try_common_feed_paths(base_url)
    base_uri = URI.parse(base_url)
    base_host = "#{base_uri.scheme}://#{base_uri.host}#{base_uri.port != base_uri.default_port ? ":#{base_uri.port}" : ''}"

    common_paths = [
      "/rss.xml",
      "/feed.xml",
      "/atom.xml",
      "/rss",
      "/feed",
      "/feeds/all.atom.xml",
      "/index.xml"
    ]

    common_paths.each do |path|
      feed_url = "#{base_host}#{path}"
      if feed_exists?(feed_url)
        return feed_url
      end
    end

    nil
  end

  def feed_exists?(feed_url)
    begin
      response = DownloadWebpageService.new.request_page(feed_url)
      return false unless response&.code == "200"

      # Check if the content type indicates it's a feed
      content_type = response.content_type&.downcase
      return true if content_type&.include?("xml") || content_type&.include?("rss") || content_type&.include?("atom")

      # Check if the content contains feed-like XML
      body = response.body
      body.include?("<rss") || body.include?("<feed") || body.include?("<atom")
    rescue DownloadWebpageServiceError => e
      false
    rescue StandardError => e
      Rails.logger.debug("Error checking feed existence for #{feed_url}: #{e.message}")
      false
    end
  end
end
