class DropSelectCourseApplies < ActiveRecord::Migration
  def up
    drop_table :select_course_applies
  end

  def down
  end
end
