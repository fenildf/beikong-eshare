class DropAnnouncements < ActiveRecord::Migration
  def up
    drop_table :announcements
    drop_table :announcement_users
  end

  def down
  end
end
