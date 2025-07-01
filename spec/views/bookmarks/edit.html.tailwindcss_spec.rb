require 'rails_helper'

RSpec.describe "bookmarks/edit", type: :view do
  let(:bookmark) {
    create(:bookmark)
  }

  before(:each) do
    assign(:bookmark, bookmark)
  end

  it "renders the edit bookmark form" do
    render

    assert_select "form[action=?][method=?]", bookmark_path(bookmark), "post" do
      assert_select "input[name=?]", "bookmark[url]"
      assert_select "input[name=?]", "bookmark[title]"
      assert_select "textarea[name=?]", "bookmark[description]"
    end
  end
end
