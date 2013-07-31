class ChangeCourseColumnType < ActiveRecord::Migration
  def change
    change_column :courses, :teach_content, :text
  end
end
