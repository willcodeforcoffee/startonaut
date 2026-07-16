require 'rails_helper'

RSpec.describe "bookmarks/new", type: :view do
  before(:each) do
    assign(:bookmark, SiteBookmark.new(
      url: "MyString",
      title: "MyString",
      description: "MyText",
      user: nil
    ))
  end

  it "renders new bookmark form" do
    render

    assert_select "form[action=?][method=?]", site_bookmarks_path, "post" do
      assert_select "input[name=?]", "site_bookmark[url]"
      assert_select "input[name=?]", "site_bookmark[title]"
      assert_select "textarea[name=?]", "site_bookmark[description]"
    end
  end
end
