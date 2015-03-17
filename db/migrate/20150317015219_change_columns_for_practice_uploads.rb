class ChangeColumnsForPracticeUploads < ActiveRecord::Migration
  def up
    remove_column :practice_uploads, :requirement_id
    remove_column :practice_uploads, :file_entity_id
    remove_column :practice_uploads, :name
    add_column :practice_uploads, :practice_id, :integer
  end

  def down
  end
end
