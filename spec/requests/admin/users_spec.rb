require 'rails_helper'

RSpec.describe "/admin/users", type: :request do
  context "when not logged in" do
    it "redirects to the login page" do
      get admin_users_url
      expect(response).to redirect_to(new_session_url)
    end
  end

  context "when logged in as a non-admin" do
    let(:authentication_user) { FactoryBot.create(:user) }

    before(:each) do
      sign_in_as(authentication_user)
    end

    it "returns HTTP 404 for the users list" do
      get admin_users_url
      expect(response).to have_http_status(:not_found)
    end

    it "returns HTTP 404 for the admin root" do
      get admin_root_url
      expect(response).to have_http_status(:not_found)
    end

    it "does not show the admin link in the navbar" do
      get pages_url
      expect(response.body).not_to include(admin_root_path)
    end
  end

  context "when logged in as an admin" do
    let(:authentication_user) { FactoryBot.create(:user, :admin) }

    before(:each) do
      sign_in_as(authentication_user)
    end

    it "renders a successful response" do
      get admin_users_url
      expect(response).to be_successful
    end

    it "shows the admin link in the navbar" do
      get pages_url
      expect(response.body).to include(admin_root_path)
    end

    it "lists users with their sign up date, last sign in, and bookmark and tag counts" do
      other_user = FactoryBot.create(:user, :with_faker_email, created_at: Time.zone.local(2026, 1, 2), last_signed_in_at: Time.zone.local(2026, 3, 4))
      FactoryBot.create(:bookmark, user: other_user, url: "https://example.com/one")
      FactoryBot.create(:bookmark, user: other_user, url: "https://example.com/two")

      get admin_users_url

      row = Nokogiri::HTML(response.body).at_css("#user_#{other_user.id}")
      cells = row.css("td").map { |td| td.text.strip }
      expect(cells[0]).to eq(other_user.email_address)
      expect(cells[1]).to eq("2026-01-02")
      expect(cells[2]).to eq("2026-03-04")
      expect(cells[3]).to eq("2")
      expect(cells[4]).to eq(other_user.tags.count.to_s)
    end
  end
end
