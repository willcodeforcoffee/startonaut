require 'rails_helper'

RSpec.describe "BookmarksFaviconProxies", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/bookmarks_favicon_proxy/show"
      expect(response).to have_http_status(:success)
    end
  end
end
