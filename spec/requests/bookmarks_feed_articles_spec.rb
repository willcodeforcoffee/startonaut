require 'rails_helper'

RSpec.describe "/bookmarks/:bookmark_id/feed_articles", type: :request do
  let(:authentication_user) { FactoryBot.create(:user) }

  before(:each) do
    sign_in_as(authentication_user)
  end

  describe "GET /index" do
    it "renders a successful response" do
      bookmark = FactoryBot.create(:bookmark, :with_feed_url, user: authentication_user)

      get bookmark_feed_articles_url(bookmark)

      expect(response).to be_successful
    end

    it "lists only articles belonging to the bookmark" do
      bookmark = FactoryBot.create(:bookmark, :with_feed_url, user: authentication_user)
      other_bookmark = FactoryBot.create(:bookmark, :with_feed_url, user: authentication_user, url: "https://other.example.com")
      article = FactoryBot.create(:feed_article, bookmark: bookmark)
      FactoryBot.create(:feed_article, bookmark: other_bookmark)

      get bookmark_feed_articles_url(bookmark)

      expect(response.body).to include(article.title)
    end

    context "when the bookmark belongs to another user" do
      it "raises a not found error" do
        other_user = FactoryBot.create(:user, :with_faker_email)
        bookmark = FactoryBot.create(:bookmark, :with_feed_url, user: other_user)

        get bookmark_feed_articles_url(bookmark)

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
