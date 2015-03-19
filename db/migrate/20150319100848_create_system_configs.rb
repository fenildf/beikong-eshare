class CreateSystemConfigs < ActiveRecord::Migration
  def change
    create_table :system_configs do |t|
      t.integer :bg_img_file_entity_id
      t.integer :logo_img_file_entity_id
      t.timestamps
    end
  end
end
