require 'rails_helper'

RSpec.describe "pages/index", type: :view do
  let(:current_user) { create(:user) }
  before(:each) do
    assign(:pages, [
      Page.create!(
        user: current_user,
        title: "Test Title",
        description: "MyText"
      ),
      Page.create!(
        user: current_user,
        title: "Test Title",
        description: "MyText"
      )
    ])
  end

  it "renders a list of pages" do
    render
    assert_select "div.page-title", text: Regexp.new("Test Title".to_s), count: 2
    assert_select "div.page-description", text: Regexp.new("MyText".to_s), count: 2
  end
end
