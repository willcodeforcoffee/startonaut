class ScanFeedsJob < ApplicationJob
  queue_as :default

  def perform
    Bookmark.with_active_feed.find_each do |bookmark|
      FetchFeedArticlesJob.perform_later(bookmark.id)
    end
  end
end
