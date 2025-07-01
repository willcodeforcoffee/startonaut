require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it "should be valid for default factorybot" do
      user = FactoryBot.build(:user)
      expect(user).to be_valid
    end

    it "should validate presence of email_address" do
      user = FactoryBot.build(:user, email_address: nil)
      expect(user).not_to be_valid
      expect(user.errors[:email_address]).to include("can't be blank")
    end

    it "should validate uniqueness of email_address" do
      existing_user = FactoryBot.create(:user)
      user = FactoryBot.build(:user, email_address: existing_user.email_address)
      expect(user).not_to be_valid
      expect(user.errors[:email_address]).to include("has already been taken")
    end

    it "should normalize email_address" do
      user = FactoryBot.build(:user, email_address: "TEST@EXAMPLE.COM")
      expect(user.email_address).to eq("test@example.com")
    end
  end
end
