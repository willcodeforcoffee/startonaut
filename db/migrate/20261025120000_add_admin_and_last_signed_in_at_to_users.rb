class AddAdminAndLastSignedInAtToUsers < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :admin, :boolean, default: false, null: false
    add_column :users, :last_signed_in_at, :datetime

    # Best-effort backfill from sessions that still exist (logging out deletes the session)
    execute <<~SQL
      UPDATE users
      SET last_signed_in_at = (SELECT MAX(sessions.created_at) FROM sessions WHERE sessions.user_id = users.id)
    SQL
  end

  def down
    remove_column :users, :last_signed_in_at
    remove_column :users, :admin
  end
end
