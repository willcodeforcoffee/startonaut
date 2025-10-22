require 'rails_helper'

RSpec.describe "ExportBookmarks", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/export_bookmarks/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/export_bookmarks/show"
      expect(response).to have_http_status(:success)
    end
  end

end
