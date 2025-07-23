require 'rails_helper'

RSpec.describe "tags/new", type: :view do
  let(:authentication_user) { FactoryBot.create(:user) }

  before(:each) do
    sign_in_as(authentication_user)

    assign(:tag, Tag.new(
      name: "MyString",
      user: authentication_user
    ))
  end

  it "renders new tag form" do
    render

    assert_select "form[action=?][method=?]", tags_path, "post" do
      assert_select "input[name=?]", "tag[name]"

      assert_select "input[name=?]", "tag[user_id]"
    end
  end
end
