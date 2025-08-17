require 'rails_helper'

RSpec.describe "/pages", type: :request do
    let(:authentication_user) { FactoryBot.create(:user) }
  before(:each) do
    sign_in_as(authentication_user)
  end

  # This should return the minimal set of attributes required to create a valid
  # Page. As you add validations to Page, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  describe "GET /index" do
    it "renders a successful response" do
      Page.create! valid_attributes
      get pages_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      page = Page.create! valid_attributes
      get page_url(page)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_page_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      page = Page.create! valid_attributes
      get edit_page_url(page)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Page" do
        expect {
          post pages_url, params: { page: valid_attributes }
        }.to change(Page, :count).by(1)
      end

      it "redirects to the created page" do
        post pages_url, params: { page: valid_attributes }
        expect(response).to redirect_to(page_url(Page.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Page" do
        expect {
          post pages_url, params: { page: invalid_attributes }
        }.to change(Page, :count).by(0)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post pages_url, params: { page: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested page" do
        page = Page.create! valid_attributes
        patch page_url(page), params: { page: new_attributes }
        page.reload
        skip("Add assertions for updated state")
      end

      it "redirects to the page" do
        page = Page.create! valid_attributes
        patch page_url(page), params: { page: new_attributes }
        page.reload
        expect(response).to redirect_to(page_url(page))
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        page = Page.create! valid_attributes
        patch page_url(page), params: { page: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested page" do
      page = Page.create! valid_attributes
      expect {
        delete page_url(page)
      }.to change(Page, :count).by(-1)
    end

    it "redirects to the pages list" do
      page = Page.create! valid_attributes
      delete page_url(page)
      expect(response).to redirect_to(pages_url)
    end
  end
end
