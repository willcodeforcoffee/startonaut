require 'rails_helper'

RSpec.describe "/admin/feature_flags", type: :request do
  context "when not logged in" do
    it "redirects to the login page" do
      get admin_feature_flags_url
      expect(response).to redirect_to(new_session_url)
    end
  end

  context "when logged in as a non-admin" do
    let(:authentication_user) { FactoryBot.create(:user) }

    before(:each) do
      sign_in_as(authentication_user)
    end

    it "returns HTTP 404 for the feature flags page" do
      get admin_feature_flags_url
      expect(response).to have_http_status(:not_found)
    end

    it "returns HTTP 404 and does not change flags on update" do
      patch admin_feature_flags_url, params: { feature_flags: { enable_new_user_registration: "1" } }

      expect(response).to have_http_status(:not_found)
      expect(FeatureFlag.count).to eq(0)
    end
  end

  context "when logged in as an admin" do
    let(:authentication_user) { FactoryBot.create(:user, :admin) }

    before(:each) do
      sign_in_as(authentication_user)
    end

    it "renders a checkbox for each feature flag" do
      get admin_feature_flags_url

      expect(response).to be_successful
      FeatureFlag::DEFINITIONS.each_key do |name|
        expect(response.body).to include(%(name="feature_flags[#{name}]"))
      end
    end

    it "reflects stored values in the checkboxes" do
      FeatureFlag.set!(:enable_user_mailer, true)

      get admin_feature_flags_url

      checkbox = Nokogiri::HTML(response.body).at_css("input[type=checkbox][name='feature_flags[enable_user_mailer]']")
      expect(checkbox["checked"]).to be_present
    end

    it "shows the env setting even when a saved setting overrides it" do
      original = ENV["FEATURE_FLAG_ENABLE_USER_MAILER"]
      ENV["FEATURE_FLAG_ENABLE_USER_MAILER"] = "true"
      FeatureFlag.set!(:enable_user_mailer, false)

      get admin_feature_flags_url

      env_setting = Nokogiri::HTML(response.body).at_css("#feature_flag_enable_user_mailer [data-env-setting]").text.squish
      expect(env_setting).to include("FEATURE_FLAG_ENABLE_USER_MAILER = true (on)")
      expect(env_setting).to include("Using saved setting")
    ensure
      ENV["FEATURE_FLAG_ENABLE_USER_MAILER"] = original
    end

    it "shows when the env var is not set" do
      original = ENV.delete("FEATURE_FLAG_ENABLE_NEW_USER_REGISTRATION")

      get admin_feature_flags_url

      env_setting = Nokogiri::HTML(response.body).at_css("#feature_flag_enable_new_user_registration [data-env-setting]").text.squish
      expect(env_setting).to include("FEATURE_FLAG_ENABLE_NEW_USER_REGISTRATION = not set (off)")
      expect(env_setting).to include("Using environment (not saved yet)")
    ensure
      ENV["FEATURE_FLAG_ENABLE_NEW_USER_REGISTRATION"] = original
    end

    it "updates flags from the submitted checkboxes" do
      patch admin_feature_flags_url, params: {
        feature_flags: { enable_new_user_registration: "1", enable_user_mailer: "0" }
      }

      expect(response).to redirect_to(admin_feature_flags_url)
      expect(FeatureFlag.enable_new_user_registration?).to be(true)
      expect(FeatureFlag.enable_user_mailer?).to be(false)
    end

    it "ignores unknown flag names" do
      patch admin_feature_flags_url, params: {
        feature_flags: { enable_user_mailer: "1", not_a_flag: "1" }
      }

      expect(response).to redirect_to(admin_feature_flags_url)
      expect(FeatureFlag.pluck(:name)).to eq([ "enable_user_mailer" ])
    end
  end
end
