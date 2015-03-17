class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.integer :file_entity_id
      t.integer :model_id
      t.string  :model_type
      t.timestamps
    end
  end
end
