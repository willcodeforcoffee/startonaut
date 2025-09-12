class CreateLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :logs do |t|
      t.string  :loggable_type, null: false
      t.bigint  :loggable_id, null: false

      t.string :severity, default: "info"
      t.string :source, default: nil
      t.string :user, default: nil
      t.text :message, null: false
      t.json :metadata, default: {}

      t.timestamps
    end

    add_index :logs, [ :loggable_type, :loggable_id ]
  end
end
