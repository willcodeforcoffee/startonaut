require 'rails_helper'

RSpec.describe "pages/new", type: :view do
  let(:current_user) { create(:user) }
  before(:each) do
    assign(:page, Page.new(
      user: current_user,
      title: "MyString",
      description: "MyText"
    ))
  end

  it "renders new page form" do
    render

    assert_select "form[action=?][method=?]", pages_path, "post" do
      assert_select "input[name=?]", "page[title]"
      assert_select "input[name=?]", "page[description]" # trix editor puts the text into an input, not textarea
    end
  end
end
