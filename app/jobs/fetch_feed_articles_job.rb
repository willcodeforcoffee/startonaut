class FetchFeedArticlesJob < ApplicationJob
  queue_as :default

  discard_on ActiveRecord::RecordNotFound

  def perform(bookmark_id)
    @bookmark = Bookmark.find(bookmark_id)
    return if @bookmark.feed_url.blank?
    return if @bookmark.error?

    Rails.logger.info("Fetching feed for bookmark #{@bookmark.id}: #{@bookmark.feed_url}")

    articles = FeedParserService.new.fetch_and_parse(@bookmark.feed_url)
    store_articles(articles)
    @bookmark.record_feed_check_success!

    Rails.logger.info("Fetched #{articles.size} article(s) for bookmark #{@bookmark.id}")

  rescue FeedParserService::FeedFetchError, FeedParserService::FeedParseError => e
    Rails.logger.warn("Feed check failed for bookmark #{@bookmark.id}: #{e.class} - #{e.message}")
    @bookmark.record_feed_check_failure!("#{e.class.name.demodulize}: #{e.message}")
  end

  private

  def store_articles(articles)
    articles.each do |article|
      next if article[:guid].blank? || article[:url].blank?

      @bookmark.feed_articles.find_or_create_by(guid: article[:guid]) do |feed_article|
        feed_article.title = article[:title]
        feed_article.url = article[:url]
        feed_article.description = article[:description]
        feed_article.published_at = article[:published_at]
      end
    end
  end
end
