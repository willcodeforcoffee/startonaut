class AddUniqueIndexToBookmarksUrl < ActiveRecord::Migration[8.1]
  def change
    add_index :bookmarks, [:url, :user_id], unique: true
  end
end
