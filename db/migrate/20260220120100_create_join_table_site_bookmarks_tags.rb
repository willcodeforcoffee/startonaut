class CreateJoinTableSiteBookmarksTags < ActiveRecord::Migration[8.0]
  def change
    create_join_table :site_bookmarks, :tags do |t|
      t.index [ :site_bookmark_id, :tag_id ]
      t.index [ :tag_id, :site_bookmark_id ]
    end
  end
end
