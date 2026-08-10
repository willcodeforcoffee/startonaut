class AddFeedTrackingToBookmarks < ActiveRecord::Migration[8.1]
  def change
    add_column :bookmarks, :feed_status, :string, default: "ok", null: false
    add_column :bookmarks, :feed_failure_count, :integer, default: 0, null: false
    add_column :bookmarks, :feed_checked_at, :datetime
    add_column :bookmarks, :feed_last_success_at, :datetime
    add_column :bookmarks, :feed_error_message, :string

    add_index :bookmarks, :feed_status
  end
end
