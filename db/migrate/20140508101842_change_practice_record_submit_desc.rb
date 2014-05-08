class ChangePracticeRecordSubmitDesc < ActiveRecord::Migration
  def change
    change_column :practice_records, :submit_desc, :text
    change_column :practice_records, :comment, :text
  end
end
