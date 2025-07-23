require 'rails_helper'

RSpec.describe "tags/edit", type: :view do
  let(:authentication_user) { FactoryBot.create(:user) }

  before(:each) do
    sign_in_as(authentication_user)
    assign(:tag, tag)
  end

  let(:tag) {
    Tag.create!(
      name: "MyString",
      user: authentication_user
    )
  }

  it "renders the edit tag form" do
    render

    assert_select "form[action=?][method=?]", tag_path(tag), "post" do
      assert_select "input[name=?]", "tag[name]"

      assert_select "input[name=?]", "tag[user_id]"
    end
  end
end
