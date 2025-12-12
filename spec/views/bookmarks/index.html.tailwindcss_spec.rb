require 'rails_helper'

RSpec.describe "bookmarks/index", type: :view do
  let(:user) { create(:user) }
  let(:bookmarks) { create_list(:bookmark, 2, :with_faker_url, user: user) }
  before(:each) do
    bookmarks.each { |b| b.save }

    assign(:bookmarks, Bookmark.all)
  end

  it "renders a list of bookmarks" do
    render
    # cell_selector = 'div>p'
    bookmarks.each do |bookmark|
      expect(rendered).to match(/#{bookmark.url}/)
      expect(rendered).to match(/#{bookmark.title}/)
      expect(rendered).to match(/#{bookmark.description}/)
      # assert_select cell_selector, text: Regexp.new(bookmark.url), count: 2
      # assert_select cell_selector, text: Regexp.new(bookmark.title), count: 2
      # assert_select cell_selector, text: Regexp.new(bookmark.description), count: 2
      # assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
    end
  end
end
