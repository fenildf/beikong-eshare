class DropCourseData < ActiveRecord::Migration
  def up
    drop_table :course_data
  end

  def down
  end
end
