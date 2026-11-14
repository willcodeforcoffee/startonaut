class RequirePublishedAtOnFeedArticles < ActiveRecord::Migration[8.1]
  def up
    # Articles from feeds without dates fall back to when they were fetched
    execute "UPDATE feed_articles SET published_at = created_at WHERE published_at IS NULL"
    change_column_null :feed_articles, :published_at, false

    # Support newest-first cursor pagination across all feeds and within a single feed
    add_index :feed_articles, [ :published_at, :id ]
    remove_index :feed_articles, [ :bookmark_id, :published_at ]
    add_index :feed_articles, [ :bookmark_id, :published_at, :id ]
  end

  def down
    remove_index :feed_articles, [ :bookmark_id, :published_at, :id ]
    add_index :feed_articles, [ :bookmark_id, :published_at ]
    remove_index :feed_articles, [ :published_at, :id ]

    change_column_null :feed_articles, :published_at, true
  end
end
