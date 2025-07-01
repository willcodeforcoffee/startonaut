class Bookmark < ApplicationRecord
  belongs_to :user
  validates :url, presence: true
  validates :user, presence: true

  normalizes :url, with: ->(e) { e.strip.downcase }
end
