class DropCourseSubjects < ActiveRecord::Migration
  def up
    drop_table :course_subjects
    drop_table :course_subject_courses
    drop_table :course_subject_managerships
    drop_table :course_subject_follows
  end

  def down
  end
end
