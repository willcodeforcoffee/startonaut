class AddIndexesToBookmarksTags < ActiveRecord::Migration[8.1]
  def change
    add_index :bookmarks_tags, [ :tag_id, :bookmark_id ]
    add_index :bookmarks_tags, :bookmark_id
  end
end
