require 'rails_helper'

RSpec.describe "/bookmarks/:bookmark_id/clicks", type: :request do
  let(:authentication_user) { FactoryBot.create(:user) }

  describe "POST /create" do
    context "when signed in" do
      before(:each) do
        sign_in_as(authentication_user)
      end

      it "records a click and responds with no content" do
        bookmark = FactoryBot.create(:bookmark, user: authentication_user)

        expect {
          post bookmark_clicks_url(bookmark)
        }.to change(bookmark.clicks, :count).by(1)

        expect(response).to have_http_status(:no_content)
      end

      it "does not record a click on another user's bookmark" do
        other_user = FactoryBot.create(:user, :with_faker_email)
        bookmark = FactoryBot.create(:bookmark, user: other_user)

        expect {
          post bookmark_clicks_url(bookmark)
        }.not_to change(BookmarkClick, :count)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when signed out" do
      it "redirects to sign in without recording a click" do
        bookmark = FactoryBot.create(:bookmark, user: authentication_user)

        expect {
          post bookmark_clicks_url(bookmark)
        }.not_to change(BookmarkClick, :count)

        expect(response).to redirect_to(new_session_url)
      end
    end
  end
end
