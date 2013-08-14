class ChangeSyllabusOfCourse < ActiveRecord::Migration
  def change
    change_column :courses, :syllabus, :text
  end
end
