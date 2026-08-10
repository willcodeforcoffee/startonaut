require 'rails_helper'

RSpec.describe "/feed_articles", type: :request do
  let(:authentication_user) { FactoryBot.create(:user) }

  before(:each) do
    sign_in_as(authentication_user)
  end

  describe "GET /index" do
    it "renders a successful response" do
      get feed_articles_url
      expect(response).to be_successful
    end

    it "only includes articles belonging to the current user's bookmarks" do
      bookmark = FactoryBot.create(:bookmark, :with_feed_url, user: authentication_user)
      own_article = FactoryBot.create(:feed_article, bookmark: bookmark, title: "Article Owned By Current User")

      other_user = FactoryBot.create(:user, :with_faker_email)
      other_bookmark = FactoryBot.create(:bookmark, :with_feed_url, user: other_user)
      other_article = FactoryBot.create(:feed_article, bookmark: other_bookmark, title: "Article Owned By Other User")

      get feed_articles_url

      expect(response.body).to include(own_article.title)
      expect(response.body).not_to include(other_article.title)
    end
  end
end
