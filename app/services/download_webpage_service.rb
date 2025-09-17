class DownloadWebpageService
  class DownloadWebpageServiceError < ServiceError; end

  require "net/http"
  require "uri"

  def request_page(url)
    uri = URI.parse(url)
    return nil unless %w[http https].include?(uri.scheme)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.open_timeout = 5
    http.read_timeout = 10

    request = Net::HTTP::Get.new(uri.request_uri)
    request["User-Agent"] = "Mozilla/5.0 (Startonaut.com Favicon Fetcher)"
    request["Accept"] = "text/html,application/xhtml+xml,image/*"

    response = http.request(request)

    Rails.logger.debug("Fetched HTML for #{bookmark.url} with response code #{html_response&.code}")

    response

  rescue StandardError => e
    Rails.logger.error("HTTP request failed for #{url}: #{e.message}")

    raise DownloadWebpageServiceError, "HTTP request failed for #{url}: #{e.message}", e
  end
end
