# Temporarily remove the index if it exists. Need to remove duplicates first using maintenance:duplicate_urls script
class RemoveUniqueIndexFromBookmarksUrl < ActiveRecord::Migration[8.1]
  def change
    if index_exists? :bookmarks, [ :url, :user_id ], unique: true
      remove_index :bookmarks, [ :url, :user_id ], unique: true
    end
  end
end
