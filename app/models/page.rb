class Page < ApplicationRecord
  belongs_to :user
  validates :title, presence: true
  validates :description, presence: true

  has_rich_text :description
end
