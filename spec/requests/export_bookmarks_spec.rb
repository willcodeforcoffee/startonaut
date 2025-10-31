require 'rails_helper'

RSpec.describe "ExportBookmarks", type: :request do
  let(:authentication_user) { FactoryBot.create(:user) }
  before(:each) do
    sign_in_as(authentication_user)
  end

  describe "GET /show" do
    it "returns http success" do
      get "/export_bookmarks/show"
      expect(response).to have_http_status(:success)
    end
  end
end
