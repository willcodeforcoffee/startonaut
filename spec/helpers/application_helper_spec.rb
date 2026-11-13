require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe "#local_time_tag" do
    it "returns nil without a datetime" do
      expect(helper.local_time_tag(nil)).to be_nil
    end

    it "renders the time in UTC for the local-time controller to convert" do
      datetime = Time.find_zone("America/Toronto").parse("2026-11-12 20:30")

      html = Capybara.string(helper.local_time_tag(datetime))
      time = html.find("time")

      expect(time.text).to eq("2026-11-13 01:30 UTC")
      expect(time[:datetime]).to eq("2026-11-13T01:30:00Z")
      expect(time["data-controller"]).to eq("local-time")
    end
  end
end
