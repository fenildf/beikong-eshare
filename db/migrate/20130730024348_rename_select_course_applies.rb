class RenameSelectCourseApplies < ActiveRecord::Migration
  def change
     remove_column  :select_course_applies, :status
     rename_table   :select_course_applies, :select_courses
  end
end
