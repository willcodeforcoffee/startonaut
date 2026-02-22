class SiteBookmark < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :tags
  has_one_attached :icon
  has_one_attached :apple_touch_icon

  after_create :download_favicons

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

  attr_accessor :tag_search

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
end
