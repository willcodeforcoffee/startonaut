require 'rails_helper'

RSpec.describe "bookmarks/show", type: :view do
  let(:bookmark) { create(:bookmark) }
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

  it "shows Never when the bookmark has not been clicked" do
    render
    expect(rendered).to match(/Clicks:<\/strong>\s*0/)
    expect(rendered).to match(/Last clicked:<\/strong>\s*Never/)
  end

  it "shows the click count and last click time" do
    create(:bookmark_click, bookmark: bookmark, clicked_at: Time.zone.parse("2026-11-01 08:15"))
    create(:bookmark_click, bookmark: bookmark, clicked_at: Time.zone.parse("2026-11-12 17:42"))

    render
    expect(rendered).to match(/Clicks:<\/strong>\s*2/)
    expect(rendered).to match(/Last clicked:<\/strong>\s*2026-11-12 17:42/)
  end

  it "tracks clicks on the bookmark links" do
    render
    expect(rendered).to include(%(data-bookmark-click-url-value="#{bookmark_clicks_path(bookmark)}"))
  end
end
