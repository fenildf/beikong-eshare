class DropPracticeRequirementAndPracticeAttach < ActiveRecord::Migration
  def up
    drop_table :practice_requirements
    drop_table :practice_attaches
  end

  def down
  end
end
