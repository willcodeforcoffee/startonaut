require 'rails_helper'

RSpec.describe "tags/index", type: :view do
  let(:authentication_user) { FactoryBot.create(:user) }

  before(:each) do
    sign_in_as(authentication_user)

    assign(:tags, [
      Tag.create!(
        name: "name1",
        user: authentication_user
      ),
      Tag.create!(
        name: "name2",
        user: authentication_user
      )
    ])
  end

  it "renders a list with both tags" do
    render
    assert_select '.tag_name', text: Regexp.new("name1".to_s), count: 1
    assert_select '.tag_name', text: Regexp.new("name2".to_s), count: 1
  end
end
