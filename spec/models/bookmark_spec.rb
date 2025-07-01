require 'rails_helper'

RSpec.describe Bookmark, type: :model do
  describe 'validations' do
    it "should be valid for default factorybot" do
      bookmark = FactoryBot.build(:bookmark)
      expect(bookmark).to be_valid
    end

    it "should validate presence of url" do
      bookmark = FactoryBot.build(:bookmark, url: nil)
      expect(bookmark).not_to be_valid
      expect(bookmark.errors[:url]).to include("can't be blank")
    end

    it "should validate presence of user" do
      bookmark = FactoryBot.build(:bookmark, user: nil)
      expect(bookmark).not_to be_valid
      expect(bookmark.errors[:user]).to include("must exist")
    end

    it "should normalize url" do
      bookmark = FactoryBot.build(:bookmark, url: "  HTTP://EXAMPLE.COM  ")
      expect(bookmark.url).to eq("http://example.com")
    end
  end
end
