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

    context 'duplicate url validation' do
      it "should validate for duplicate url per user" do
        user = FactoryBot.create(:user)
        FactoryBot.create(:bookmark, user: user, url: "http://example.com")
        duplicate_bookmark = FactoryBot.build(:bookmark, user: user, url: "http://example.com")
        expect(duplicate_bookmark).not_to be_valid
        expect(duplicate_bookmark.errors[:url]).to include("has already been bookmarked")
      end

      it "should validate for duplicate normalized url per user" do
        user = FactoryBot.create(:user)
        FactoryBot.create(:bookmark, user: user, url: "http://example.com")
        duplicate_bookmark = FactoryBot.build(:bookmark, user: user, url: "http://example.com")
        expect(duplicate_bookmark).not_to be_valid
        expect(duplicate_bookmark.errors[:url]).to include("has already been bookmarked")
      end

      it "should allow the same url for different users" do
        user1 = FactoryBot.create(:user, email_address: "user1@example.com")
        user2 = FactoryBot.create(:user, email_address: "user2@example.com")
        bookmark1 = FactoryBot.create(:bookmark, user: user1, url: "http://example.com")
        bookmark2 = FactoryBot.build(:bookmark, user: user2, url: "http://example.com")

        expect(bookmark1).to be_valid
        expect(bookmark2).to be_valid
        expect(bookmark2.save).to be_truthy
      end
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

  describe '.search_by_title' do
    let(:user) { FactoryBot.create(:user) }

    it "finds bookmarks with a matching title" do
      bookmark = FactoryBot.create(:bookmark, user: user, title: "Ruby on Rails Guides")
      FactoryBot.create(:bookmark, user: user, url: "https://example.com/other", title: "Something else")
      # Misleading examples
      FactoryBot.create(:bookmark, user: user, url: "https://train.com/", title: "Railway Adventures")
      FactoryBot.create(:bookmark, user: user, url: "https://railjourney.com/", title: "Rail Journey")

      expect(Bookmark.search_by_title("rails")).to eq([ bookmark ])
    end

    it "is case-insensitive" do
      bookmark = FactoryBot.create(:bookmark, user: user, title: "Ruby on Rails Guides")
      FactoryBot.create(:bookmark, user: user, url: "https://example.com/other", title: "Something else")
      # Misleading examples
      FactoryBot.create(:bookmark, user: user, url: "https://train.com/", title: "Railway Adventures")
      FactoryBot.create(:bookmark, user: user, url: "https://railjourney.com/", title: "Rail Journey")

      expect(Bookmark.search_by_title("RAILS")).to eq([ bookmark ])
    end

    it "matches a partial substring anywhere in the title" do
      bookmark = FactoryBot.create(:bookmark, user: user, title: "Ruby on Rails Guides")

      expect(Bookmark.search_by_title("on rai")).to eq([ bookmark ])
    end

    it "returns no results when nothing matches" do
      FactoryBot.create(:bookmark, user: user, title: "Ruby on Rails Guides")

      expect(Bookmark.search_by_title("nonexistent")).to be_empty
    end

    it "returns all bookmarks for a blank query" do
      bookmark1 = FactoryBot.create(:bookmark, user: user, title: "Ruby on Rails Guides")
      bookmark2 = FactoryBot.create(:bookmark, user: user, url: "https://example.com/other", title: "Something else")

      expect(Bookmark.search_by_title("")).to contain_exactly(bookmark1, bookmark2)
    end
  end
end
