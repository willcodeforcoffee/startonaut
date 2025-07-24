require 'rails_helper'

RSpec.describe "tags/show", type: :view do
  let(:authentication_user) { FactoryBot.create(:user) }

  before(:each) do
    sign_in_as(authentication_user)

    assign(:tag, Tag.create!(
      name: "Name",
      user: authentication_user
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
  end
end
