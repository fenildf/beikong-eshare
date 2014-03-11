class RemoveFileEntityIdAndNameInPracticeUploads < ActiveRecord::Migration
  def change
    remove_column :practice_uploads, :file_entity_id
    remove_column :practice_uploads, :name
  end
end
