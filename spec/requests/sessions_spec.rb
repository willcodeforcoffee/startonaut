require 'rails_helper'

RSpec.describe "/session", type: :request do
  let(:user) { FactoryBot.create(:user) }

  describe "POST /create" do
    it "records when the user last signed in" do
      post session_url, params: { email_address: user.email_address, password: "Password123" }

      expect(response).to redirect_to(root_url)
      expect(user.reload.last_signed_in_at).to be_within(1.minute).of(Time.current)
    end

    it "does not record a sign in for a wrong password" do
      post session_url, params: { email_address: user.email_address, password: "wrong" }

      expect(user.reload.last_signed_in_at).to be_nil
    end
  end
end
