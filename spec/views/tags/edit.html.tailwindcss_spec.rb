require 'rails_helper'

RSpec.describe "tags/edit", type: :view do
  let(:tag) {
    Tag.create!(
      name: "MyString",
      user: nil
    )
  }

  before(:each) do
    assign(:tag, tag)
  end

  it "renders the edit tag form" do
    render

    assert_select "form[action=?][method=?]", tag_path(tag), "post" do

      assert_select "input[name=?]", "tag[name]"

      assert_select "input[name=?]", "tag[user_id]"
    end
  end
end
