class Bookmark < ApplicationRecord
  MAX_FEED_FAILURES = 3

  belongs_to :user
  has_and_belongs_to_many :tags
  has_many :feed_articles, dependent: :destroy
  has_one_attached :icon
  has_one_attached :apple_touch_icon

  after_create :download_favicons
  after_update :reset_feed_status_if_feed_url_changed

  validates :title, presence: true
  validates :url,
    presence: true,
    format: {
      with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
      message: "must be a valid HTTP or HTTPS URL"
    },
    uniqueness: {
      scope: :user_id,
      message: "has already been bookmarked"
    }
  validates :feed_url,
    allow_nil: true,
    allow_blank: true,
    format: {
      with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
      message: "must be a valid HTTP or HTTPS URL"
    }
  validates :user, presence: true

  normalizes :url, with: ->(e) { e.strip.downcase }
  normalizes :feed_url, with: ->(e) { e&.strip&.downcase }

  # Virtual attributes for tag handling
  attr_accessor :tag_search

  scope :search_by_title, ->(query) { where("LOWER(title) LIKE ?", "%#{query.downcase}%") }
  scope :with_active_feed, -> { where.not(feed_url: [ nil, "" ]).where(feed_status: "ok") }

  def tag_list
    tags.pluck(:name).join(", ")
  end

  def tag_list_no_spaces
    tags.pluck(:name).join(",")
  end

  def tag_list=(names)
    self.tags = names.split(",").map(&:strip).reject(&:blank?).map do |name|
      user.tags.find_or_create_by(name: name.downcase)
    end
  end

  def download_favicons
    DownloadFaviconsJob.perform_later(id)
  end

  def error?
    feed_status == "error"
  end

  def record_feed_check_success!
    update!(
      feed_status: "ok",
      feed_failure_count: 0,
      feed_checked_at: Time.current,
      feed_last_success_at: Time.current,
      feed_error_message: nil
    )
  end

  def record_feed_check_failure!(message)
    new_failure_count = feed_failure_count + 1

    update!(
      feed_failure_count: new_failure_count,
      feed_checked_at: Time.current,
      feed_error_message: message,
      feed_status: new_failure_count >= MAX_FEED_FAILURES ? "error" : "ok"
    )
  end

  def retry_feed!
    update!(feed_status: "ok", feed_failure_count: 0, feed_error_message: nil)
  end

  private

  def reset_feed_status_if_feed_url_changed
    return unless saved_change_to_feed_url?
    return if feed_status == "ok" && feed_failure_count.zero?

    update_columns(feed_status: "ok", feed_failure_count: 0, feed_error_message: nil)
  end
end
