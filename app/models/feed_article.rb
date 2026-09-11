class FeedArticle < ApplicationRecord
  belongs_to :bookmark

  validates :guid, presence: true, uniqueness: { scope: :bookmark_id }
  validates :url,
    presence: true,
    format: {
      with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
      message: "must be a valid HTTP or HTTPS URL"
    }

  scope :recent_first, -> { order(published_at: :desc, created_at: :desc) }
end
