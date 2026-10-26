require 'rails_helper'

RSpec.describe FeatureFlag, type: :model do
  around(:each) do |example|
    original = ENV["FEATURE_FLAG_ENABLE_USER_MAILER"]
    example.run
  ensure
    ENV["FEATURE_FLAG_ENABLE_USER_MAILER"] = original
  end

  describe ".enabled?" do
    it "falls back to the env var when no value is stored" do
      ENV["FEATURE_FLAG_ENABLE_USER_MAILER"] = "true"
      expect(FeatureFlag.enabled?(:enable_user_mailer)).to be(true)

      ENV["FEATURE_FLAG_ENABLE_USER_MAILER"] = "false"
      expect(FeatureFlag.enabled?(:enable_user_mailer)).to be(false)
    end

    it "prefers the stored value over the env var" do
      ENV["FEATURE_FLAG_ENABLE_USER_MAILER"] = "true"
      FeatureFlag.set!(:enable_user_mailer, false)

      expect(FeatureFlag.enabled?(:enable_user_mailer)).to be(false)
      expect(FeatureFlag.enable_user_mailer?).to be(false)
    end

    it "raises for an unknown flag" do
      expect { FeatureFlag.enabled?(:not_a_flag) }.to raise_error(ArgumentError)
    end
  end

  describe ".set!" do
    it "creates or updates the stored value" do
      FeatureFlag.set!(:enable_new_user_registration, true)
      FeatureFlag.set!(:enable_new_user_registration, false)

      expect(FeatureFlag.where(name: "enable_new_user_registration").pluck(:enabled)).to eq([ false ])
    end

    it "raises for an unknown flag" do
      expect { FeatureFlag.set!(:not_a_flag, true) }.to raise_error(ArgumentError)
    end
  end
end
