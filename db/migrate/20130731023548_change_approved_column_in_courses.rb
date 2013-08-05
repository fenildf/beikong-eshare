class ChangeApprovedColumnInCourses < ActiveRecord::Migration
  def change
    remove_column :courses, :is_approved
    add_column :courses, :approve_status, :string
  end
end
