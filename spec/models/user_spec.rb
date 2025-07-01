require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it "should be valid for default factorybot" do
      user = FactoryBot.build(:user)
      expect(user).to be_valid
    end
  end
end
