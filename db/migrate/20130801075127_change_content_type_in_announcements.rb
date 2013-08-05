class ChangeContentTypeInAnnouncements < ActiveRecord::Migration
  def change
    change_column :announcements, :content, :text
  end
end
