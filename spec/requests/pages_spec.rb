require 'rails_helper'

RSpec.describe "Pages", type: :request do
  let(:authentication_user) { FactoryBot.create(:user) }
  before(:each) do
    sign_in_as(authentication_user)
  end

  describe "GET /index" do
    it "returns http success" do
      get "/pages"
      expect(response).to have_http_status(:success)
    end
  end
end
