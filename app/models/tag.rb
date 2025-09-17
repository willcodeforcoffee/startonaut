class Tag < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :bookmarks

  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :user, presence: true

  normalizes :name, with: ->(e) { e.strip.downcase }

  scope :favorites, -> { where(favorite: true) }
end
