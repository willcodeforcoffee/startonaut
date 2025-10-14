require 'rails_helper'

RSpec.describe "Accounts", type: :request do
  context "when not logged in" do
    describe "GET" do
      it "returns HTTP 302 FOUND" do
        get "/account"
        expect(response).to have_http_status(:found)
      end
    end
  end

  context "when logged in" do
    let(:authentication_user) { FactoryBot.create(:user) }
    before(:each) do
      sign_in_as(authentication_user)
    end

    describe "GET" do
      it "returns HTTP 200 OK" do
        get "/account"
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
