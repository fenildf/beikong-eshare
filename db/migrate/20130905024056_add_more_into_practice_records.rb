class AddMoreIntoPracticeRecords < ActiveRecord::Migration
  def change
    add_column :practice_records, :score, :integer, :null => true
    add_column :practice_records, :comment, :string
    add_column :practice_records, :is_submitted_offline, :boolean, :null => false, :default => false
    add_column :practice_records, :submit_desc, :string
    add_column :practice_records, :submitted_offline_at, :datetime

  end
end
