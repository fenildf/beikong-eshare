class AddOnTopToAnnouncements < ActiveRecord::Migration
  def change
    add_column :announcements, :on_top, :boolean
  end
end
