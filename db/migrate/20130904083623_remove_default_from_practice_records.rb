class RemoveDefaultFromPracticeRecords < ActiveRecord::Migration
  def up
    change_column_default :practice_records, :score, nil
  end
end
