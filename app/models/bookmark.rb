class Bookmark < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :tags

  validates :url, presence: true, format: {
    with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
    message: "must be a valid HTTP or HTTPS URL"
  }
  validates :user, presence: true

  normalizes :url, with: ->(e) { e.strip.downcase }

  def tag_list
    tags.pluck(:name).join(", ")
  end

  def tag_list=(names)
    self.tags = names.split(",").map(&:strip).reject(&:blank?).map do |name|
      user.tags.find_or_create_by(name: name.downcase)
    end
  end
end
