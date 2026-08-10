require 'rails_helper'

RSpec.describe FeedParserService do
  let(:service) { described_class.new }
  let(:feed_url) { "https://example.com/feed" }

  let(:rss_xml) do
    <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <rss version="2.0">
        <channel>
          <title>Example Feed</title>
          <link>https://example.com</link>
          <description>desc</description>
          <item>
            <title>Item 1</title>
            <link>https://example.com/1</link>
            <description>Item 1 body</description>
            <guid>guid-1</guid>
            <pubDate>Sat, 08 Aug 2026 12:00:00 GMT</pubDate>
          </item>
          <item>
            <title>Item 2 no guid</title>
            <link>https://example.com/2</link>
            <description>Item 2 body</description>
            <pubDate>Sat, 08 Aug 2026 13:00:00 GMT</pubDate>
          </item>
        </channel>
      </rss>
    XML
  end

  let(:atom_xml) do
    <<~XML
      <?xml version="1.0" encoding="utf-8"?>
      <feed xmlns="http://www.w3.org/2005/Atom">
        <title>Example Atom Feed</title>
        <link href="https://example.com/atom" rel="self"/>
        <updated>2026-08-08T12:00:00Z</updated>
        <id>https://example.com/</id>
        <entry>
          <title>Atom Entry 1</title>
          <link href="https://example.com/atom/1"/>
          <id>atom-guid-1</id>
          <updated>2026-08-08T12:00:00Z</updated>
          <summary>Entry 1 summary</summary>
        </entry>
        <entry>
          <title>Atom Entry 2 no id</title>
          <link href="https://example.com/atom/2"/>
          <updated>2026-08-08T13:00:00Z</updated>
          <summary>Entry 2 summary</summary>
        </entry>
      </feed>
    XML
  end

  def stub_download(body:, code: "200")
    download_service = instance_double(DownloadWebpageService)
    allow(DownloadWebpageService).to receive(:new).and_return(download_service)
    allow(download_service).to receive(:request_page).with(feed_url)
      .and_return(instance_double(Net::HTTPResponse, body: body, code: code))
    download_service
  end

  describe "#fetch_and_parse" do
    it "parses a valid RSS 2.0 feed into normalized article hashes" do
      stub_download(body: rss_xml)

      articles = service.fetch_and_parse(feed_url)

      expect(articles.size).to eq(2)
      expect(articles.first).to include(
        title: "Item 1",
        url: "https://example.com/1",
        description: "Item 1 body",
        guid: "guid-1"
      )
    end

    it "falls back to the link as guid when an RSS item has none" do
      stub_download(body: rss_xml)

      articles = service.fetch_and_parse(feed_url)

      expect(articles.second[:guid]).to eq("https://example.com/2")
    end

    it "parses a valid Atom feed into normalized article hashes" do
      stub_download(body: atom_xml)

      articles = service.fetch_and_parse(feed_url)

      expect(articles.size).to eq(2)
      expect(articles.first).to include(
        title: "Atom Entry 1",
        url: "https://example.com/atom/1",
        description: "Entry 1 summary",
        guid: "atom-guid-1"
      )
    end

    it "falls back to the link href as guid when an Atom entry has no id" do
      stub_download(body: atom_xml)

      articles = service.fetch_and_parse(feed_url)

      expect(articles.second[:guid]).to eq("https://example.com/atom/2")
    end

    it "raises FeedParseError for an HTML error page body" do
      stub_download(body: "<html><body>404 not found</body></html>")

      expect { service.fetch_and_parse(feed_url) }.to raise_error(FeedParserService::FeedParseError)
    end

    it "raises FeedParseError for malformed XML" do
      stub_download(body: "not even xml <<<")

      expect { service.fetch_and_parse(feed_url) }.to raise_error(FeedParserService::FeedParseError)
    end

    it "raises FeedFetchError for a non-200 response" do
      stub_download(body: "", code: "404")

      expect { service.fetch_and_parse(feed_url) }.to raise_error(FeedParserService::FeedFetchError)
    end

    it "raises FeedFetchError when the download service raises" do
      download_service = instance_double(DownloadWebpageService)
      allow(DownloadWebpageService).to receive(:new).and_return(download_service)
      allow(download_service).to receive(:request_page).with(feed_url)
        .and_raise(DownloadWebpageService::DownloadWebpageServiceError, "boom")

      expect { service.fetch_and_parse(feed_url) }.to raise_error(FeedParserService::FeedFetchError)
    end
  end
end
