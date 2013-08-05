class AddStatusInSelectCourses < ActiveRecord::Migration
  def change
    add_column :select_courses, :status, :string
  end
end
