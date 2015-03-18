class AddColumnsForPracticeRecords < ActiveRecord::Migration
  def up
    add_column :practice_records, :score, :integer
    add_column :practice_records, :comment, :text
    add_column :practice_records, :is_submitted_offline, :boolean, :default => false, :null => false
    add_column :practice_records, :submit_desc, :text
  end

  def down
  end
end
