class DropCourseDepends < ActiveRecord::Migration
  def up
    drop_table :course_depends
  end

  def down
  end
end
