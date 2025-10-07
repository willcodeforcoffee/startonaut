require 'rails_helper'

RSpec.describe Bookmark, type: :model do
  describe 'validations' do
    it "should be valid for default from FactoryBot" do
      bookmark = FactoryBot.build(:bookmark)
      expect(bookmark).to be_valid
    end

    it "should validate presence of url" do
      bookmark = FactoryBot.build(:bookmark, url: nil)
      expect(bookmark).not_to be_valid
      expect(bookmark.errors[:url]).to include("can't be blank")
    end


    context 'unsafe urls' do
      it "should not allow invalid URLs" do
        bookmark = FactoryBot.build(:bookmark, url: "invalid_url")
        expect(bookmark).not_to be_valid
        expect(bookmark.errors[:url]).to include("must be a valid HTTP or HTTPS URL")
      end

      it "should allow valid URLs" do
        bookmark = FactoryBot.build(:bookmark, url: "http://example.com")
        expect(bookmark).to be_valid
      end

      it "should stop javascript URLs" do
        bookmark = FactoryBot.build(:bookmark, url: "javascript:alert('XSS')")
        expect(bookmark).not_to be_valid
        expect(bookmark.errors[:url]).to include("must be a valid HTTP or HTTPS URL")
      end

      it "should not pass just because http is in the URL" do
        bookmark = FactoryBot.build(:bookmark, url: "ftp://https.example.com")
        expect(bookmark).not_to be_valid
        expect(bookmark.errors[:url]).to include("must be a valid HTTP or HTTPS URL")
      end
    end

    context 'feed_url validation' do
      it "should allow nil feed_url" do
        bookmark = FactoryBot.build(:bookmark, feed_url: nil)
        expect(bookmark).to be_valid
      end

      it "should allow valid HTTP feed URLs" do
        bookmark = FactoryBot.build(:bookmark, feed_url: "http://example.com/rss.xml")
        expect(bookmark).to be_valid
      end

      it "should allow valid HTTPS feed URLs" do
        bookmark = FactoryBot.build(:bookmark, feed_url: "https://example.com/feed.xml")
        expect(bookmark).to be_valid
      end

      it "should not allow invalid feed URLs" do
        bookmark = FactoryBot.build(:bookmark, feed_url: "invalid_feed_url")
        expect(bookmark).not_to be_valid
        expect(bookmark.errors[:feed_url]).to include("must be a valid HTTP or HTTPS URL")
      end

      it "should not allow FTP feed URLs" do
        bookmark = FactoryBot.build(:bookmark, feed_url: "ftp://example.com/feed.xml")
        expect(bookmark).not_to be_valid
        expect(bookmark.errors[:feed_url]).to include("must be a valid HTTP or HTTPS URL")
      end

      it "should not allow feed URLs without protocol" do
        bookmark = FactoryBot.build(:bookmark, feed_url: "example.com/rss.xml")
        expect(bookmark).not_to be_valid
        expect(bookmark.errors[:feed_url]).to include("must be a valid HTTP or HTTPS URL")
      end

      it "should not allow javascript URLs in feed_url" do
        bookmark = FactoryBot.build(:bookmark, feed_url: "javascript:alert('XSS')")
        expect(bookmark).not_to be_valid
        expect(bookmark.errors[:feed_url]).to include("must be a valid HTTP or HTTPS URL")
      end
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
