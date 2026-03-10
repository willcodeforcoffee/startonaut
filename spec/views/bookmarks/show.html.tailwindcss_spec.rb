require 'rails_helper'

RSpec.describe "bookmarks/show", type: :view do
  let(:bookmark) { create(:site_bookmark) }
  before(:each) do
    assign(:bookmark, bookmark)
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/#{bookmark.url}/)
    expect(rendered).to match(/#{bookmark.title}/)
    expect(rendered).to match(/#{bookmark.description}/)
    # expect(rendered).to match(//)
  end
end
