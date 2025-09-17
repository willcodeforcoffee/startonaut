class AddFavoriteToTags < ActiveRecord::Migration[8.0]
  def change
    add_column :tags, :favorite, :boolean, default: false, null: false
  end
end
