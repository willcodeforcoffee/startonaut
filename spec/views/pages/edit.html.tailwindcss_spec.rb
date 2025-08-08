require 'rails_helper'

RSpec.describe "pages/edit", type: :view do
  let(:current_user) { create(:user) }
  let(:page) {
    Page.create!(
      user: current_user,
      title: "MyString",
      description: "MyText"
    )
  }

  before(:each) do
    assign(:page, page)
  end

  it "renders the edit page form" do
    render

    assert_select "form[action=?][method=?]", page_path(page), "post" do
      assert_select "input[name=?]", "page[title]"
      assert_select "input[name=?]", "page[description]" # trix editor puts the text into an input, not textarea
    end
  end
end
