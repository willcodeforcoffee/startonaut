require 'rails_helper'

RSpec.describe "pages/show", type: :view do
  let(:current_user) { create(:user) }
  before(:each) do
    assign(:page, Page.create!(
      user: current_user,
      title: "Title",
      description: "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/MyText/)
  end
end
