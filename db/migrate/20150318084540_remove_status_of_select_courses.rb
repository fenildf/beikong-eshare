class RemoveStatusOfSelectCourses < ActiveRecord::Migration
  def up
    remove_column :select_courses, :status
  end

  def down
  end
end
