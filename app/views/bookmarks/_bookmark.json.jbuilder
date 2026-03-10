json.extract! bookmark, :id, :url, :title, :description, :created_at, :updated_at
json.url site_bookmark_url(bookmark, format: :json)
