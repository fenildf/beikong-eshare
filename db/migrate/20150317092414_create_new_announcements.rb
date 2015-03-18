class CreateNewAnnouncements < ActiveRecord::Migration
  def change
    create_table :announcements do |t|
      t.integer  :creator_id
      t.string  :title
      t.text  :content
      t.boolean :on_top, :default => false

      t.integer  :host_id
      t.string  :host_type

      t.timestamps
    end
  end
end
