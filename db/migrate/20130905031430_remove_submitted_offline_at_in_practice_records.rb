class RemoveSubmittedOfflineAtInPracticeRecords < ActiveRecord::Migration
  def change
    remove_column :practice_records, :submitted_offline_at
  end
end
