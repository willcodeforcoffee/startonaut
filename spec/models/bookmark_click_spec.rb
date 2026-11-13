require 'rails_helper'

RSpec.describe BookmarkClick, type: :model do
  it "belongs to a bookmark" do
    expect(described_class.new(clicked_at: Time.current)).not_to be_valid
  end

  it "defaults clicked_at to the current time" do
    click = create(:bookmark).clicks.create!

    expect(click.clicked_at).to be_within(1.second).of(Time.current)
  end
end
