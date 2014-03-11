class ChangeRequirementIdInPracticeUploads < ActiveRecord::Migration
  def change
    rename_column :practice_uploads, :requirement_id, :practice_id
    drop_table :practice_requirements
  end
end
