require 'rails_helper'

RSpec.describe "tags/index", type: :view do
  let(:authentication_user) { FactoryBot.create(:user) }

  before(:each) do
    sign_in_as(authentication_user)

    assign(:tags, [
      Tag.create!(
        name: "Name1",
        user: authentication_user
      ),
      Tag.create!(
        name: "Name2",
        user: authentication_user
      )
    ])
  end

  it "renders a list of tags" do
    render
    cell_selector = 'div>strong'
    assert_select cell_selector, text: Regexp.new("Name".to_s), count: 2
    assert_select cell_selector, text: Regexp.new(nil.to_s), count: 2
  end
end
