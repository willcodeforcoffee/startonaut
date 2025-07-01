json.extract! bookmark, :id, :url, :title, :description, :created_at, :updated_at
json.url bookmark_url(bookmark, format: :json)
