require "rss"

class FeedParserService
  class FeedFetchError < ServiceError; end
  class FeedParseError < ServiceError; end

  def fetch_and_parse(feed_url)
    response = download_feed(feed_url)
    validate_response!(response, feed_url)
    parse(response.body)
  end

  private

  def download_feed(feed_url)
    DownloadFeedService.new.request_page(feed_url)
  rescue DownloadFeedService::DownloadFeedServiceError => e
    raise FeedFetchError.new("Could not download feed #{feed_url}: #{e.message}", e)
  end

  def validate_response!(response, feed_url)
    raise FeedFetchError, "No response received for #{feed_url}" if response.nil?
    raise FeedFetchError, "Feed #{feed_url} returned HTTP #{response.code}" unless response.code == "200"
  end

  def parse(xml_body)
    feed = RSS::Parser.parse(xml_body, false)
    raise FeedParseError, "Feed content could not be recognized as RSS or Atom" if feed.nil?

    normalize(feed)
  rescue RSS::Error, REXML::ParseException => e
    raise FeedParseError.new("Failed to parse feed XML: #{e.message}", e)
  end

  def normalize(feed)
    feed.is_a?(RSS::Atom::Feed) ? normalize_atom(feed) : normalize_rss(feed)
  end

  def normalize_rss(feed)
    feed.items.map do |item|
      link = item.link
      {
        title: item.title,
        url: link,
        description: item.description,
        guid: item.guid&.content.presence || link,
        published_at: item.pubDate || item.date
      }
    end
  end

  def normalize_atom(feed)
    feed.entries.map do |entry|
      link = entry.link&.href || entry.links&.first&.href
      {
        title: entry.title&.content,
        url: link,
        description: entry.summary&.content || entry.content&.content,
        guid: entry.id&.content.presence || link,
        published_at: entry.updated&.content || entry.published&.content
      }
    end
  end
end
