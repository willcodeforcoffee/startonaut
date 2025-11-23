class AddCanDeleteToTags < ActiveRecord::Migration[8.1]
  def change
    add_column :tags, :can_delete, :boolean, default: false, null: true
  end
end
