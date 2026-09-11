require 'rails_helper'

RSpec.describe FetchFeedArticlesJob, type: :job do
  let(:user) { create(:user) }
  let(:bookmark) { create(:bookmark, :with_feed_url, user: user) }

  let(:articles) do
    [
      { title: "Item 1", url: "https://example.com/1", description: "d1", guid: "guid-1", published_at: 1.day.ago },
      { title: "Item 2", url: "https://example.com/2", description: "d2", guid: "guid-2", published_at: 2.days.ago }
    ]
  end

  def stub_parser(return_value: nil, error: nil)
    parser = instance_double(FeedParserService)
    allow(FeedParserService).to receive(:new).and_return(parser)
    if error
      allow(parser).to receive(:fetch_and_parse).with(bookmark.feed_url).and_raise(error)
    else
      allow(parser).to receive(:fetch_and_parse).with(bookmark.feed_url).and_return(return_value)
    end
    parser
  end

  describe "#perform" do
    context "when the feed fetches and parses successfully" do
      it "creates a FeedArticle for each normalized article" do
        stub_parser(return_value: articles)

        expect {
          described_class.perform_now(bookmark.id)
        }.to change(FeedArticle, :count).by(2)
      end

      it "resets the bookmark's feed status and stamps success timestamps" do
        stub_parser(return_value: articles)

        described_class.perform_now(bookmark.id)
        bookmark.reload

        expect(bookmark.feed_status).to eq("ok")
        expect(bookmark.feed_failure_count).to eq(0)
        expect(bookmark.feed_checked_at).to be_present
        expect(bookmark.feed_last_success_at).to be_present
      end

      it "does not create duplicate articles on a re-run with the same guids" do
        stub_parser(return_value: articles)
        described_class.perform_now(bookmark.id)

        expect {
          described_class.perform_now(bookmark.id)
        }.not_to change(FeedArticle, :count)
      end
    end

    context "when the feed fails to fetch or parse" do
      it "increments the failure count without erroring below the threshold" do
        stub_parser(error: FeedParserService::FeedFetchError.new("network down"))

        described_class.perform_now(bookmark.id)
        bookmark.reload

        expect(bookmark.feed_failure_count).to eq(1)
        expect(bookmark.feed_status).to eq("ok")
        expect(bookmark.feed_error_message).to include("network down")
      end

      it "marks the feed as errored on the 3rd consecutive failure" do
        stub_parser(error: FeedParserService::FeedParseError.new("bad xml"))

        3.times { described_class.perform_now(bookmark.id) }
        bookmark.reload

        expect(bookmark.feed_failure_count).to eq(3)
        expect(bookmark.feed_status).to eq("error")
      end

      it "does not create any articles" do
        stub_parser(error: FeedParserService::FeedFetchError.new("network down"))

        expect {
          described_class.perform_now(bookmark.id)
        }.not_to change(FeedArticle, :count)
      end
    end

    context "when the bookmark's feed is already in error status" do
      let(:bookmark) { create(:bookmark, :with_feed_error, user: user) }

      it "skips the fetch entirely" do
        expect(FeedParserService).not_to receive(:new)

        described_class.perform_now(bookmark.id)
      end
    end

    context "when the bookmark has no feed_url" do
      let(:bookmark) { create(:bookmark, user: user, feed_url: nil) }

      it "skips the fetch entirely" do
        expect(FeedParserService).not_to receive(:new)

        described_class.perform_now(bookmark.id)
      end
    end

    context "when the bookmark no longer exists" do
      it "does not raise" do
        expect { described_class.perform_now(-1) }.not_to raise_error
      end
    end
  end

  describe "job configuration" do
    it "is configured to run on the default queue" do
      expect(described_class.queue_name).to eq("default")
    end
  end
end
