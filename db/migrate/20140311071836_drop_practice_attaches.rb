class DropPracticeAttaches < ActiveRecord::Migration
  def change
    drop_table :practice_attaches
  end
end
