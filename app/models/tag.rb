class Tag < ApplicationRecord
  # Default tags that are created for each new user
  READ_LATER = "read later".freeze
  USER_DEFAULT_TAGS = [
    READ_LATER,
    "sunday",
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
    "saturday"
  ].freeze

  belongs_to :user
  has_and_belongs_to_many :bookmarks

  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :user, presence: true

  normalizes :name, with: ->(e) { e.strip.downcase }

  scope :favorites, -> { where(favorite: true) }
  scope :read_later, -> { where(name: READ_LATER) }
  scope :today_tag, -> { where(name: todays_name) }

  def self.todays_name
    Date::DAYNAMES[Date.today.wday].downcase
  end
end
