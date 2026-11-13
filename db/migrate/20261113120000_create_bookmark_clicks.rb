class CreateBookmarkClicks < ActiveRecord::Migration[8.1]
  def change
    create_table :bookmark_clicks do |t|
      t.references :bookmark, null: false, foreign_key: true
      t.datetime :clicked_at, null: false

      t.timestamps
    end

    add_index :bookmark_clicks, [ :bookmark_id, :clicked_at ]
  end
end
