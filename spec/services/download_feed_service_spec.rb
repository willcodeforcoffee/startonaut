require 'rails_helper'

RSpec.describe DownloadFeedService do
  let(:service) { described_class.new }
  let(:feed_url) { "https://example.com/feed" }

  it "requests the page with a feed-oriented Accept header" do
    webpage_service = instance_double(DownloadWebpageService)
    allow(DownloadWebpageService).to receive(:new).and_return(webpage_service)
    response = instance_double(Net::HTTPResponse)
    allow(webpage_service).to receive(:request_page)
      .with(feed_url, accept: DownloadFeedService::FEED_ACCEPT)
      .and_return(response)

    expect(service.request_page(feed_url)).to eq(response)
  end

  it "advertises RSS, Atom and XML in the Accept header" do
    expect(DownloadFeedService::FEED_ACCEPT).to include(
      "application/rss+xml", "application/atom+xml", "application/xml"
    )
  end

  it "wraps download errors in DownloadFeedServiceError" do
    webpage_service = instance_double(DownloadWebpageService)
    allow(DownloadWebpageService).to receive(:new).and_return(webpage_service)
    allow(webpage_service).to receive(:request_page)
      .and_raise(DownloadWebpageService::DownloadWebpageServiceError, "boom")

    expect { service.request_page(feed_url) }
      .to raise_error(DownloadFeedService::DownloadFeedServiceError, /boom/)
  end
end
