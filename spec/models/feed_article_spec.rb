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

  describe ".recent_first" do
    it "orders articles by published_at descending" do
      bookmark = FactoryBot.create(:bookmark)
      older = FactoryBot.create(:feed_article, bookmark: bookmark, published_at: 2.days.ago)
      newer = FactoryBot.create(:feed_article, bookmark: bookmark, published_at: 1.hour.ago)

      expect(bookmark.feed_articles.recent_first).to eq([ newer, older ])
    end
  end
end
