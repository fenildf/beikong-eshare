class RemoveColumnsOfCourses < ActiveRecord::Migration
  def up
    remove_column :courses, :apply_request_limit
    remove_column :courses, :approve_status
    remove_column :courses, :status
  end

  def down
  end
end
