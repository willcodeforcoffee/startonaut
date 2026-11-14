require 'rails_helper'

# Walks every page of the river-of-news feeds by following the lazy Turbo Frame at the bottom
# of each page, the same way the browser does while scrolling.
RSpec.describe "Feed article paging", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:base_time) { Time.zone.parse("2026-11-01 12:00:00") }

  before(:each) do
    sign_in_as(user)
  end

  # 60 articles (pages of 25, 25 and 10), newest first. Articles 22-28 share one timestamp across
  # the page 1/2 boundary, and articles 47-52 differ only by microseconds across the page 2/3 boundary.
  def create_articles(bookmarks)
    Array.new(60) do |i|
      published_at =
        if (22..28).cover?(i) then base_time - 22.minutes
        elsif (47..52).cover?(i) then base_time - 47.minutes - (i * 0.000001)
        else base_time - i.minutes
        end

      FactoryBot.create(:feed_article, bookmark: bookmarks[i % bookmarks.size], published_at: published_at)
    end
  end

  def newest_first_ids(articles)
    articles.map(&:reload).sort_by { |article| [ article.published_at, article.id ] }.reverse.map(&:id)
  end

  def walk_pages(url)
    seen_ids = []
    page_sizes = []
    frame_id = nil

    10.times do |page_number|
      get url, headers: (frame_id ? { "Turbo-Frame" => frame_id } : {})
      expect(response).to be_successful

      html = Nokogiri::HTML(response.body)
      ids = html.css("[id^='feed_article_']").map { |node| node[:id].delete_prefix("feed_article_").to_i }
      seen_ids.concat(ids)
      page_sizes << ids.size
      yield page_number if block_given?

      next_frame = html.at_css("turbo-frame[src]")
      return [ seen_ids, page_sizes, response.body ] unless next_frame

      url = next_frame[:src]
      frame_id = next_frame[:id]
    end

    raise "pagination did not terminate"
  end

  shared_examples "a river of news" do
    it "pages through every article exactly once, newest first" do
      expected_ids = newest_first_ids(articles)

      seen_ids, page_sizes, last_body = walk_pages(first_page_url)

      expect(seen_ids).to eq(seen_ids.uniq)
      expect(seen_ids).to eq(expected_ids)
      expect(page_sizes).to eq([ 25, 25, 10 ])
      expect(last_body).to include("You're all caught up")
    end

    it "does not repeat or skip articles when a new one arrives while scrolling" do
      expected_ids = newest_first_ids(articles)
      new_article = nil

      seen_ids, = walk_pages(first_page_url) do |page_number|
        if page_number.zero?
          new_article = FactoryBot.create(:feed_article, bookmark: articles.first.bookmark, published_at: base_time + 1.minute)
        end
      end

      expect(seen_ids).not_to include(new_article.id)
      expect(seen_ids).to eq(expected_ids)
    end

    it "never shows another user's articles" do
      other_bookmark = FactoryBot.create(:bookmark, user: FactoryBot.create(:user, :with_faker_email))
      other_ids = Array.new(5) { |i| FactoryBot.create(:feed_article, bookmark: other_bookmark, published_at: base_time - (i * 10).minutes).id }
      articles

      seen_ids, = walk_pages(first_page_url)

      expect(seen_ids & other_ids).to be_empty
    end
  end

  describe "GET /feed_articles" do
    let(:bookmarks) do
      [
        FactoryBot.create(:bookmark, :with_feed_url, user: user),
        FactoryBot.create(:bookmark, :with_feed_url, user: user, url: "https://other.example.com")
      ]
    end
    let!(:articles) { create_articles(bookmarks) }
    let(:first_page_url) { feed_articles_path }

    it_behaves_like "a river of news"
  end

  describe "GET /bookmarks/:bookmark_id/feed_articles" do
    let(:bookmark) { FactoryBot.create(:bookmark, :with_feed_url, user: user) }
    let!(:articles) { create_articles([ bookmark ]) }
    let(:first_page_url) { bookmark_feed_articles_path(bookmark) }

    it_behaves_like "a river of news"
  end
end
