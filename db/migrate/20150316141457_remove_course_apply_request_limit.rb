class RemoveCourseApplyRequestLimit < ActiveRecord::Migration
  def up
    remove_column :courses, :apply_request_limit
  end

  def down
  end
end
