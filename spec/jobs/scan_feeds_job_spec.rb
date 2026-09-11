require 'rails_helper'

RSpec.describe ScanFeedsJob, type: :job do
  include ActiveJob::TestHelper

  let(:user) { create(:user) }

  describe "#perform" do
    it "enqueues FetchFeedArticlesJob for bookmarks with a feed_url and ok status" do
      bookmark = create(:bookmark, :with_feed_url, user: user)

      expect {
        described_class.perform_now
      }.to have_enqueued_job(FetchFeedArticlesJob).with(bookmark.id)
    end

    it "does not enqueue for bookmarks with a blank feed_url" do
      create(:bookmark, user: user, feed_url: nil)

      expect {
        described_class.perform_now
      }.not_to have_enqueued_job(FetchFeedArticlesJob)
    end

    it "does not enqueue for bookmarks with an errored feed status" do
      create(:bookmark, :with_feed_error, user: user)

      expect {
        described_class.perform_now
      }.not_to have_enqueued_job(FetchFeedArticlesJob)
    end
  end
end
