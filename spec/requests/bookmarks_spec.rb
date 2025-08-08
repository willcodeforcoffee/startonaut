require 'rails_helper'

RSpec.describe "/bookmarks", type: :request do
  let(:authentication_user) { FactoryBot.create(:user) }
  before(:each) do
    sign_in_as(authentication_user)
  end

  let(:bookmark) { build(:bookmark, user: authentication_user) }
  let(:valid_attributes) { bookmark.attributes.except("id", "created_at", "updated_at") }
  let(:invalid_attributes) { { url: nil, title: nil } }

  describe "GET /index" do
    it "renders a successful response" do
      get bookmarks_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      bookmark = create(:bookmark, user: authentication_user)
      get bookmark_url(bookmark)
      expect(response).to be_successful
    end

    context "when the bookmark belongs to another user" do
      it "raises an error" do
        other_user = create(:user, :with_faker_email)
        bookmark = create(:bookmark, user: other_user)

        get bookmark_url(bookmark)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_bookmark_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      bookmark.save!

      get edit_bookmark_url(bookmark)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Bookmark" do
        expect {
          post bookmarks_url, params: { bookmark: valid_attributes }
        }.to change(Bookmark, :count).by(1)
      end

      it "redirects to the created bookmark" do
        post bookmarks_url, params: { bookmark: valid_attributes }
        expect(response).to redirect_to(bookmark_url(Bookmark.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Bookmark" do
        expect {
          post bookmarks_url, params: { bookmark: invalid_attributes }
        }.to change(Bookmark, :count).by(0)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post bookmarks_url, params: { bookmark: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      before(:each) do
        bookmark.save!
      end

      it "updates the requested bookmark" do
        patch bookmark_url(bookmark), params: { bookmark: { title: "New Title", description: "New Description" } }

        bookmark.reload

        expect(bookmark.title).to eq("New Title")
        expect(bookmark.description).to eq("New Description")
      end

      it "redirects to the bookmark" do
        patch bookmark_url(bookmark), params: { bookmark: valid_attributes }
        bookmark.reload
        expect(response).to redirect_to(bookmark_url(bookmark))
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        bookmark = create(:bookmark, user: authentication_user)
        patch bookmark_url(bookmark), params: { bookmark: { url: nil, title: nil } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested bookmark" do
      bookmark = create(:bookmark, user: authentication_user)
      expect {
        delete bookmark_url(bookmark)
      }.to change(Bookmark, :count).by(-1)
    end

    it "redirects to the bookmarks list" do
      bookmark = create(:bookmark, user: authentication_user)
      delete bookmark_url(bookmark)
      expect(response).to redirect_to(bookmarks_url)
    end
  end
end
