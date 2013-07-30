class AddLogicColumnsInCourses < ActiveRecord::Migration
  def change
    add_column :courses, :lesson_hour, :integer
    add_column :courses, :credit, :integer
    add_column :courses, :least_user_count, :integer
    add_column :courses, :most_user_count, :integer
    change_column :courses, :syllabus,      :string
    add_column    :courses, :teach_type,    :string
    add_column    :courses, :teach_content, :string
  end
end
