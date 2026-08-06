require 'rails_helper'

RSpec.describe "Pages", type: :request do
  let(:authentication_user) { FactoryBot.create(:user) }
  before(:each) do
    sign_in_as(authentication_user)
  end

  describe "GET /index (/pages/index)" do
    it "returns http success" do
      get "/pages"
      expect(response).to have_http_status(:success)
    end

    context "with a q search parameter" do
      let!(:matching_bookmark) { FactoryBot.create(:bookmark, user: authentication_user, title: "Ruby on Rails Guides", url: "https://rubyonrails.org") }
      let!(:other_bookmark) { FactoryBot.create(:bookmark, user: authentication_user, title: "Elixir Docs", url: "https://elixir-lang.org") }

      it "returns http success" do
        get "/pages", params: { q: "ruby" }
        expect(response).to have_http_status(:success)
      end

      it "only shows bookmarks matching the search query" do
        get "/pages", params: { q: "ruby" }
        expect(response.body).to include(matching_bookmark.title)
        expect(response.body).not_to include(other_bookmark.title)
      end

      it "returns no bookmarks when nothing matches" do
        get "/pages", params: { q: "nonexistent" }
        expect(response.body).not_to include(matching_bookmark.title)
        expect(response.body).not_to include(other_bookmark.title)
      end
    end
  end

  describe "POST /pages/search" do
    it "redirects to the pages index with the q parameter" do
      post "/pages/search", params: { q: "ruby" }
      expect(response).to redirect_to(pages_path(q: "ruby"))
    end

    it "redirects to the pages index without a q parameter when none is given" do
      post "/pages/search"
      expect(response).to redirect_to(pages_path(q: nil))
    end
  end
end
