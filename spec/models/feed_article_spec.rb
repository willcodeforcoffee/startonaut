require 'rails_helper'

RSpec.describe FeedArticle, type: :model do
  describe "validations" do
    it "is valid for default from FactoryBot" do
      expect(FactoryBot.build(:feed_article)).to be_valid
    end

    it "validates presence of guid" do
      article = FactoryBot.build(:feed_article, guid: nil)
      expect(article).not_to be_valid
      expect(article.errors[:guid]).to include("can't be blank")
    end

    it "validates presence of url" do
      article = FactoryBot.build(:feed_article, url: nil)
      expect(article).not_to be_valid
      expect(article.errors[:url]).to include("can't be blank")
    end

    it "validates url format" do
      article = FactoryBot.build(:feed_article, url: "not a url")
      expect(article).not_to be_valid
      expect(article.errors[:url]).to include("must be a valid HTTP or HTTPS URL")
    end

    it "validates uniqueness of guid scoped to bookmark" do
      bookmark = FactoryBot.create(:bookmark)
      FactoryBot.create(:feed_article, bookmark: bookmark, guid: "dup-guid")
      duplicate = FactoryBot.build(:feed_article, bookmark: bookmark, guid: "dup-guid")

      expect(duplicate).not_to be_valid
    end

    it "allows the same guid across different bookmarks" do
      FactoryBot.create(:feed_article, guid: "shared-guid")
      other = FactoryBot.build(:feed_article, guid: "shared-guid")

      expect(other).to be_valid
    end
  end

  describe "published_at" do
    it "defaults to the current time when the feed has no date" do
      article = FactoryBot.create(:feed_article, published_at: nil)

      expect(article.published_at).to be_within(1.second).of(Time.current)
    end
  end

  describe ".recent_first" do
    it "orders articles by published_at descending" do
      bookmark = FactoryBot.create(:bookmark)
      older = FactoryBot.create(:feed_article, bookmark: bookmark, published_at: 2.days.ago)
      newer = FactoryBot.create(:feed_article, bookmark: bookmark, published_at: 1.hour.ago)

      expect(bookmark.feed_articles.recent_first).to eq([ newer, older ])
    end

    it "orders articles with the same published_at by id descending" do
      bookmark = FactoryBot.create(:bookmark)
      time = 1.hour.ago
      first = FactoryBot.create(:feed_article, bookmark: bookmark, published_at: time)
      second = FactoryBot.create(:feed_article, bookmark: bookmark, published_at: time)

      expect(bookmark.feed_articles.recent_first).to eq([ second, first ])
    end
  end

  describe ".before_cursor" do
    it "returns articles older than the cursor, breaking timestamp ties by id" do
      bookmark = FactoryBot.create(:bookmark)
      time = Time.zone.parse("2026-11-01 12:00:00")
      newer = FactoryBot.create(:feed_article, bookmark: bookmark, published_at: time + 1.second)
      tied_lower = FactoryBot.create(:feed_article, bookmark: bookmark, published_at: time)
      cursor_article = FactoryBot.create(:feed_article, bookmark: bookmark, published_at: time)
      tied_higher = FactoryBot.create(:feed_article, bookmark: bookmark, published_at: time)
      older = FactoryBot.create(:feed_article, bookmark: bookmark, published_at: time - 1.second)

      results = bookmark.feed_articles.recent_first.before_cursor(cursor_article.published_at, cursor_article.id)

      expect(results).to eq([ tied_lower, older ])
      expect(results).not_to include(newer, tied_higher, cursor_article)
    end
  end

  describe ".page_before" do
    let(:bookmark) { FactoryBot.create(:bookmark) }

    it "returns the first page and a cursor for the next one" do
      articles = Array.new(FeedArticle::PAGE_SIZE + 1) do |i|
        FactoryBot.create(:feed_article, bookmark: bookmark, published_at: i.minutes.ago)
      end

      page, next_cursor = bookmark.feed_articles.recent_first.page_before(nil)

      expect(page).to eq(articles.first(FeedArticle::PAGE_SIZE))
      expect(next_cursor).to eq(page.last.cursor)
    end

    it "returns no cursor on the last page" do
      articles = Array.new(3) { |i| FactoryBot.create(:feed_article, bookmark: bookmark, published_at: i.minutes.ago) }

      page, next_cursor = bookmark.feed_articles.recent_first.page_before(articles.first.cursor)

      expect(page).to eq(articles.drop(1))
      expect(next_cursor).to be_nil
    end

    it "keeps microsecond precision in the cursor" do
      time = Time.zone.parse("2026-11-01 12:00:00")
      later = FactoryBot.create(:feed_article, bookmark: bookmark, published_at: time + 0.000002)
      earlier = FactoryBot.create(:feed_article, bookmark: bookmark, published_at: time + 0.000001)

      page, = bookmark.feed_articles.recent_first.page_before(later.reload.cursor)

      expect(page).to eq([ earlier ])
    end

    [ "garbage", "not-a-time_12", "2026-11-01T12:00:00Z_abc", "" ].each do |cursor|
      it "treats the invalid cursor #{cursor.inspect} as the first page" do
        article = FactoryBot.create(:feed_article, bookmark: bookmark)

        page, next_cursor = bookmark.feed_articles.recent_first.page_before(cursor)

        expect(page).to eq([ article ])
        expect(next_cursor).to be_nil
      end
    end
  end
end
