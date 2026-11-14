require 'rails_helper'

RSpec.describe "Tag filtering", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:ruby) { FactoryBot.create(:tag, name: "ruby", user: user) }
  let(:rails) { FactoryBot.create(:tag, name: "rails", user: user) }

  let!(:both_bookmark) { tagged_bookmark("Both Ruby And Rails", "https://both.example.com", ruby, rails) }
  let!(:ruby_bookmark) { tagged_bookmark("Only Ruby", "https://ruby.example.com", ruby) }
  let!(:rails_bookmark) { tagged_bookmark("Only Rails", "https://rails.example.com", rails) }
  let!(:untagged_bookmark) { tagged_bookmark("No Tags", "https://untagged.example.com") }

  before(:each) do
    sign_in_as(user)
  end

  def tagged_bookmark(title, url, *tags)
    FactoryBot.create(:bookmark, :with_feed_url, user: user, title: title, url: url).tap { it.tags << tags }
  end

  # The count shown next to the tag link that points at the given path
  def tag_count(href)
    count = Nokogiri::HTML(response.body).css("a[href='#{href}'] span.opacity-60").first
    count.text[/\d+/].to_i
  end

  def bookmark_titles_on_start_page
    Nokogiri::HTML(response.body).css("ul[role='list'] li p").map { it.text.strip }
  end

  describe "GET /pages" do
    it "shows all bookmarks when no tag is selected" do
      get pages_path

      expect(bookmark_titles_on_start_page).to contain_exactly(
        "Both Ruby And Rails", "Only Ruby", "Only Rails", "No Tags"
      )
    end

    it "shows only bookmarks with the selected tag" do
      get pages_path(tags: "ruby")

      expect(bookmark_titles_on_start_page).to contain_exactly("Both Ruby And Rails", "Only Ruby")
    end

    it "shows only bookmarks with all of the selected tags" do
      get pages_path(tags: "ruby,rails")

      expect(bookmark_titles_on_start_page).to contain_exactly("Both Ruby And Rails")
    end

    it "shows no bookmarks for a tag the user doesn't have" do
      other_user = FactoryBot.create(:user, :with_faker_email)
      FactoryBot.create(:bookmark, user: other_user, url: "https://other.example.com")
        .tags << FactoryBot.create(:tag, name: "elixir", user: other_user)

      get pages_path(tags: "elixir")

      expect(bookmark_titles_on_start_page).to be_empty
      expect(response.body).to include("No bookmarks have all of the selected tags.")
    end

    it "filters the Read Later panel too" do
      read_later = user.tags.find_or_create_by!(name: Tag::READ_LATER)
      both_bookmark.tags << read_later
      rails_bookmark.tags << read_later

      get pages_path(tags: "ruby")

      panel = Nokogiri::HTML(response.body).css("h2").find { it.text == "Read Later Bookmarks" }.parent
      expect(panel.text).to include("Both Ruby And Rails")
      expect(panel.text).not_to include("Only Rails")
    end

    it "links tags to add or remove them from the filter" do
      get pages_path(tags: "ruby")

      html = Nokogiri::HTML(response.body)
      expect(html.at_css("a[href='#{pages_path(tags: "ruby,rails")}']")).to be_present
      expect(html.at_css("a[href='#{pages_path}'][aria-pressed='true']")).to be_present
    end

    it "keeps the search query when filtering" do
      get pages_path(q: "only", tags: "ruby")

      expect(bookmark_titles_on_start_page).to contain_exactly("Only Ruby")
      expect(Nokogiri::HTML(response.body).at_css("a[href='#{pages_path(q: "only", tags: "ruby,rails")}']")).to be_present
    end

    it "counts all of a tag's bookmarks when no tag is selected" do
      get pages_path

      expect(tag_count(pages_path(tags: "ruby"))).to eq(2)
      expect(tag_count(pages_path(tags: "rails"))).to eq(2)
    end

    it "counts only bookmarks that match the tag filter" do
      get pages_path(tags: "ruby")

      expect(tag_count(pages_path)).to eq(2) # ruby, selected
      expect(tag_count(pages_path(tags: "ruby,rails"))).to eq(1)
    end

    it "counts only bookmarks that match the search" do
      get pages_path(q: "only")

      expect(tag_count(pages_path(q: "only", tags: "ruby"))).to eq(1)
      expect(tag_count(pages_path(q: "only", tags: "rails"))).to eq(1)
    end

    it "keeps the tag filter in the search form" do
      get pages_path(tags: "ruby,rails")

      field = Nokogiri::HTML(response.body).at_css("#search input[type='hidden'][name='tags']")
      expect(field[:value]).to eq("ruby,rails")
    end
  end

  describe "POST /pages/search" do
    it "keeps the tag filter and adds the search term" do
      post search_pages_path, params: { q: "only", tags: "ruby" }

      expect(response).to redirect_to(pages_path(q: "only", tags: "ruby"))
      follow_redirect!
      expect(bookmark_titles_on_start_page).to contain_exactly("Only Ruby")
    end

    it "searches all bookmarks when no tag is selected" do
      post search_pages_path, params: { q: "only" }

      expect(response).to redirect_to(pages_path(q: "only"))
    end
  end

  describe "GET /feed_articles" do
    let!(:articles) do
      [ both_bookmark, ruby_bookmark, rails_bookmark, untagged_bookmark ].to_h do |bookmark|
        [ bookmark, FactoryBot.create(:feed_article, bookmark: bookmark, title: "Article from #{bookmark.title}") ]
      end
    end

    def article_titles
      Nokogiri::HTML(response.body).css("[id^='feed_article_'] a[target='_blank']").map { it.text.strip }
    end

    it "shows all articles when no tag is selected" do
      get feed_articles_path

      expect(article_titles).to contain_exactly(*articles.values.map(&:title))
    end

    it "shows only articles from bookmarks with the selected tag" do
      get feed_articles_path(tags: "ruby")

      expect(article_titles).to contain_exactly("Article from Both Ruby And Rails", "Article from Only Ruby")
    end

    it "shows only articles from bookmarks with all of the selected tags" do
      get feed_articles_path(tags: "ruby,rails")

      expect(article_titles).to contain_exactly("Article from Both Ruby And Rails")
    end

    it "shows an empty message when no bookmarks have all of the tags" do
      get feed_articles_path(tags: "ruby,missing")

      expect(article_titles).to be_empty
      expect(response.body).to include("No articles from bookmarks with all of the selected tags.")
    end

    it "shows the tag list with links that filter the feed" do
      get feed_articles_path

      expect(tag_count(feed_articles_path(tags: "ruby"))).to eq(2)
      expect(tag_count(feed_articles_path(tags: "rails"))).to eq(2)
    end

    it "counts only bookmarks that match the tag filter" do
      get feed_articles_path(tags: "rails")

      expect(tag_count(feed_articles_path(tags: "rails,ruby"))).to eq(1)
      expect(tag_count(feed_articles_path)).to eq(2) # rails, selected
    end
  end
end
