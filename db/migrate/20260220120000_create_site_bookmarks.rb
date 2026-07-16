class CreateSiteBookmarks < ActiveRecord::Migration[8.0]
  def change
    create_table :site_bookmarks do |t|
      t.string :url, null: false
      t.string :title
      t.text :description
      t.string :feed_url
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :site_bookmarks, [ :url, :user_id ], unique: true
  end
end
