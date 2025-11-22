class Tag < ApplicationRecord
  # Default tags that are created for each new user
  USER_DEFAULT_TAGS = [
    "read later",
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
end
