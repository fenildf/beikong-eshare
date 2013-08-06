class AddDefaultValueInCourses < ActiveRecord::Migration
  def change
    change_column_default(:courses, :least_user_count, 5) 
    change_column_default(:courses, :most_user_count, 20) 
    change_column_default(:courses, :lesson_hour, 16) 
    change_column_default(:courses, :credit, 2) 
  end
end
