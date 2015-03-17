class RemoveStatusOfCourses < ActiveRecord::Migration
  def up
    remove_column :courses, :status
  end

  def down
  end
end
