require 'rails_helper'

RSpec.describe DownloadFaviconsJob, type: :job do
  let(:user) { create(:user) }
  let(:bookmark) { create(:site_bookmark, user: user, url: "https://example.com") }

  # Sample HTML responses
  let(:html_with_icons) do
    <<~HTML
      <html>
        <head>
          <title>html_with_icons</title>
          <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png">
          <link rel="icon" type="image/svg+xml" href="/favicon.svg">
          <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon-180x180.png">
          <link rel="apple-touch-icon" sizes="152x152" href="/apple-touch-icon-152x152.png">
        </head>
      </html>
    HTML
  end

  let(:html_with_relative_icons) do
    <<~HTML
      <html>
        <head>
          <title>html_with_relative_icons</title>
          <link rel="icon" href="./assets/favicon.ico">
          <link rel="apple-touch-icon" href="../icons/apple-touch-icon.png">
        </head>
      </html>
    HTML
  end

  let(:html_without_icons) do
    <<~HTML
      <html>
        <head>
          <title>html_without_icons</title>
        </head>
        <body>
          <h1>html_without_icons</h1>
        </body>
      </html>
    HTML
  end

  let(:mock_html_response) do
    dbl = instance_double(Net::HTTPResponse, body: html_with_icons)
    allow(dbl).to receive(:code).and_return("200")
    dbl
  end

  describe '#perform' do
    context 'when bookmark exists' do
      it 'calls DownloadWebpageService to fetch HTML' do
        download_service = instance_double(DownloadWebpageService)
        allow(DownloadWebpageService).to receive(:new).and_return(download_service)
        allow(download_service).to receive(:request_page).with(bookmark.url).and_return(mock_html_response)

        # Mock icon download attempts to avoid actual HTTP calls
        allow_any_instance_of(DownloadFaviconsJob).to receive(:download_and_attach_icon).and_return(true)

        expect(download_service).to receive(:request_page).with(bookmark.url)

        described_class.perform_now(bookmark.id)
      end

      it 'handles pages without any icon links' do
        download_service = instance_double(DownloadWebpageService)
        allow(DownloadWebpageService).to receive(:new).and_return(download_service)
        allow(download_service).to receive(:request_page).with(bookmark.url)
          .and_return(instance_double(Net::HTTPResponse, body: html_without_icons, code: "200"))

        # Should not attempt any downloads
        expect_any_instance_of(DownloadFaviconsJob).not_to receive(:download_and_attach_icon)

        described_class.perform_now(bookmark.id)
      end

      it 'handles non-success (200) HTTP responses' do
        download_service = instance_double(DownloadWebpageService)
        allow(DownloadWebpageService).to receive(:new).and_return(download_service)
        allow(download_service).to receive(:request_page).with(bookmark.url)
          .and_return(instance_double(Net::HTTPResponse, body: html_without_icons, code: "301"))

        # Should not attempt any downloads
        expect_any_instance_of(DownloadFaviconsJob).not_to receive(:download_and_attach_icon)

        described_class.perform_now(bookmark.id)
      end    end
  end

  describe '#prioritize_icon_links' do
    let(:job) { described_class.new }

    it 'prioritizes SVG over PNG over ICO' do
      doc = Nokogiri::HTML(<<~HTML)
        <link rel="icon" type="image/ico" href="/favicon.ico">
        <link rel="icon" type="image/png" href="/favicon.png">
        <link rel="icon" type="image/svg+xml" href="/favicon.svg">
      HTML

      links = doc.css('link[rel*="icon"]')
      prioritized = job.send(:prioritize_icon_links, links)

      expect(prioritized.first['href']).to eq('/favicon.svg')
      expect(prioritized.second['href']).to eq('/favicon.png')
      expect(prioritized.last['href']).to eq('/favicon.ico')
    end

    it 'prioritizes larger sizes' do
      doc = Nokogiri::HTML(<<~HTML)
        <link rel="icon" type="image/png" sizes="16x16" href="/favicon-16.png">
        <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32.png">
        <link rel="icon" type="image/png" sizes="64x64" href="/favicon-64.png">
      HTML

      links = doc.css('link[rel*="icon"]')
      prioritized = job.send(:prioritize_icon_links, links)

      expect(prioritized.first['href']).to eq('/favicon-64.png')
      expect(prioritized.second['href']).to eq('/favicon-32.png')
      expect(prioritized.last['href']).to eq('/favicon-16.png')
    end
  end

  describe '#prioritize_apple_icon_links' do
    let(:job) { described_class.new }

    it 'prioritizes larger sizes' do
      doc = Nokogiri::HTML(<<~HTML)
        <link rel="apple-touch-icon" sizes="152x152" href="/apple-touch-icon-152.png">
        <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon-180.png">
        <link rel="apple-touch-icon" sizes="120x120" href="/apple-touch-icon-120.png">
      HTML

      links = doc.css('link[rel*="apple-touch-icon"]')
      prioritized = job.send(:prioritize_apple_icon_links, links)

      expect(prioritized.first['href']).to eq('/apple-touch-icon-180.png')
      expect(prioritized.second['href']).to eq('/apple-touch-icon-152.png')
      expect(prioritized.last['href']).to eq('/apple-touch-icon-120.png')
    end
  end

  describe '#resolve_url' do
    let(:job) { described_class.new }
    let(:base_uri) { URI.parse("https://example.com/path/to/page") }

    it 'resolves protocol-relative URLs' do
      result = job.send(:resolve_url, "//cdn.example.com/icon.png", base_uri)
      expect(result).to eq("https://cdn.example.com/icon.png")
    end

    it 'resolves absolute path URLs' do
      result = job.send(:resolve_url, "/assets/favicon.ico", base_uri)
      expect(result).to eq("https://example.com/assets/favicon.ico")
    end

    it 'resolves relative path URLs' do
      result = job.send(:resolve_url, "../icons/favicon.png", base_uri)
      expect(result).to eq("https://example.com/path/to/../icons/favicon.png")
    end

    it 'returns absolute URLs unchanged' do
      result = job.send(:resolve_url, "https://cdn.example.com/icon.png", base_uri)
      expect(result).to eq("https://cdn.example.com/icon.png")
    end

    it 'handles URLs with custom ports' do
      base_uri_with_port = URI.parse("https://example.com:8080/path")
      result = job.send(:resolve_url, "/favicon.ico", base_uri_with_port)
      expect(result).to eq("https://example.com:8080/favicon.ico")
    end
  end

  describe '#valid_image_content_type?' do
    let(:job) { described_class.new }

    it 'accepts valid image content types' do
      valid_types = [
        "image/png",
        "image/jpg",
        "image/jpeg",
        "image/gif",
        "image/svg+xml",
        "image/x-icon",
        "image/vnd.microsoft.icon",
        "image/ico"
      ]

      valid_types.each do |content_type|
        expect(job.send(:valid_image_content_type?, content_type)).to be true
      end
    end

    it 'rejects invalid content types' do
      invalid_types = [
        "text/html",
        "application/json",
        "text/plain",
        nil,
        ""
      ]

      invalid_types.each do |content_type|
        expect(job.send(:valid_image_content_type?, content_type)).to be false
      end
    end
  end

  describe '#file_extension_for_content_type' do
    let(:job) { described_class.new }

    it 'returns correct extensions for content types' do
      expectations = {
        "image/png" => ".png",
        "image/jpg" => ".jpg",
        "image/jpeg" => ".jpg",
        "image/gif" => ".gif",
        "image/svg+xml" => ".svg",
        "image/x-icon" => ".ico",
        "unknown/type" => ".png"
      }

      expectations.each do |content_type, expected_extension|
        expect(job.send(:file_extension_for_content_type, content_type)).to eq(expected_extension)
      end
    end
  end

  describe 'job configuration' do
    it 'is configured to run on the default queue' do
      expect(described_class.queue_name).to eq('default')
    end

    it 'is an ApplicationJob' do
      expect(described_class.superclass).to eq(ApplicationJob)
    end
  end
end
