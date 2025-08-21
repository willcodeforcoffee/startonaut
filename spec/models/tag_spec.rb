require 'rails_helper'

RSpec.describe Tag, type: :model do
  context "validation" do
    it "should be valid for default from FactoryBot" do
      tag = build(:tag)
      expect(tag).to be_valid
    end

    it "should validate the presence of name" do
      tag = build(:tag, name: nil)
      expect(tag).not_to be_valid
      expect(tag.errors[:name]).to include("can't be blank")
    end

    it "should validate the presence of user" do
      tag = build(:tag, user: nil)
      expect(tag).not_to be_valid
      expect(tag.errors[:user]).to include("must exist")
    end
  end

  context "normalization" do
    it "downcases the name" do
      tag = Tag.new(name: "TEST")
      expect(tag.name).to eq("test")
    end
  end
end
