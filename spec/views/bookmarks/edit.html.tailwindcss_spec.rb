require 'rails_helper'

RSpec.describe "bookmarks/edit", type: :view do
  let(:bookmark) {
    create(:site_bookmark)
  }

  before(:each) do
    assign(:bookmark, bookmark)
  end

  it "renders the edit bookmark form" do
    render

    assert_select "form[action=?][method=?]", site_bookmark_path(bookmark), "post" do
      assert_select "input[name=?]", "site_bookmark[url]"
      assert_select "input[name=?]", "site_bookmark[title]"
      assert_select "textarea[name=?]", "site_bookmark[description]"
    end
  end
end
