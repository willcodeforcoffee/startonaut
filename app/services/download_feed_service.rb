class DownloadFeedService
  class DownloadFeedServiceError < ServiceError; end

  # Feed endpoints often return HTML (or a 406) unless the client advertises
  # that it accepts RSS/Atom/XML, so ask for those first while still keeping
  # the HTML types as a fallback for misconfigured servers.
  FEED_ACCEPT = [
    "application/rss+xml",
    "application/atom+xml",
    "application/xml",
    "text/xml",
    "text/html;q=0.5",
    "application/xhtml+xml;q=0.5"
  ].join(",").freeze

  def request_page(url)
    DownloadWebpageService.new.request_page(url, accept: FEED_ACCEPT)
  rescue DownloadWebpageService::DownloadWebpageServiceError => e
    raise DownloadFeedServiceError.new(e.message, e)
  end
end
