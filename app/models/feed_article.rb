class FeedArticle < ApplicationRecord
  PAGE_SIZE = 25

  belongs_to :bookmark

  before_validation { self.published_at ||= Time.current }

  validates :guid, presence: true, uniqueness: { scope: :bookmark_id }
  validates :url,
    presence: true,
    format: {
      with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
      message: "must be a valid HTTP or HTTPS URL"
    }

  scope :recent_first, -> { order(published_at: :desc, id: :desc) }
  scope :before_cursor, ->(published_at, id) {
    where("(feed_articles.published_at, feed_articles.id) < (?, ?)", published_at, id)
  }

  # Returns one page of articles older than the cursor (the first page when the cursor is
  # blank or invalid) and the cursor for the next page, which is nil on the last page.
  # Call it on a relation ordered by recent_first.
  def self.page_before(cursor)
    published_at, id = parse_cursor(cursor)
    scope = published_at ? before_cursor(published_at, id) : all
    articles = scope.limit(PAGE_SIZE + 1).to_a

    if articles.size > PAGE_SIZE
      articles = articles.first(PAGE_SIZE)
      [ articles, articles.last.cursor ]
    else
      [ articles, nil ]
    end
  end

  def self.parse_cursor(cursor)
    time, _, id = cursor.to_s.rpartition("_")
    [ Time.iso8601(time), Integer(id) ]
  rescue ArgumentError
    [ nil, nil ]
  end

  # Identifies this article's position in recent_first order, to the microsecond
  def cursor
    "#{published_at.utc.iso8601(6)}_#{id}"
  end
end
