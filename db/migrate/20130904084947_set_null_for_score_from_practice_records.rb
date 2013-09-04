class SetNullForScoreFromPracticeRecords < ActiveRecord::Migration
  def up
    change_column :practice_records, :score, :integer, :null => true
  end

  def down
  end
end
