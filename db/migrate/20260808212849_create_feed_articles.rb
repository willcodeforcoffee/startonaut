class CreateFeedArticles < ActiveRecord::Migration[8.1]
  def change
    create_table :feed_articles do |t|
      t.references :bookmark, null: false, foreign_key: true
      t.string :title
      t.string :url
      t.text :description
      t.string :guid
      t.datetime :published_at

      t.timestamps
    end

    add_index :feed_articles, [ :bookmark_id, :guid ], unique: true
    add_index :feed_articles, [ :bookmark_id, :published_at ]
  end
end
