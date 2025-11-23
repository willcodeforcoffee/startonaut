class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :bookmarks, dependent: :destroy
  has_many :tags, dependent: :destroy

  validates :email_address, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.blank? }

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  after_create :create_default_tags

  private

  def create_default_tags
    CreateDefaultUserTagsJob.perform_later(id)
  end
end
