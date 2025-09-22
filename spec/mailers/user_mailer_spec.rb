require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "welcome_email" do
    let(:to_email_address) { "to@example.org" }
    let(:user) { FactoryBot.create(:user, email_address: to_email_address) }
    let(:mail) { UserMailer.welcome_email(user) }

    before(:each) do
      allow(FeatureFlag).to receive(:enable_user_mailer?).and_return(true)
    end

    context "rendering headers" do
      it "renders subject" do
        expect(mail.subject).to eq(UserMailer::WELCOME_SUBJECT)
      end

      it "renders 'to' address" do
        expect(mail.to).to eq([ to_email_address ])
      end

      it "renders 'from' address" do
        expect(mail.from).to eq([ "welcome@startonaut.com" ])
      end
    end
  end
end
