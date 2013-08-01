class AddForRoleInAnnouncements < ActiveRecord::Migration
  def change
    add_column :announcements, :for_role, :string
  end
end
