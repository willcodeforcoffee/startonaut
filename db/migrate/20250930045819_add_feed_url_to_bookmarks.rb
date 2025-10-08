class AddFeedUrlToBookmarks < ActiveRecord::Migration[8.0]
  def change
    add_column :bookmarks, :feed_url, :string
  end
end
