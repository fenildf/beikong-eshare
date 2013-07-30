class AddTimestampsToCourseScores < ActiveRecord::Migration
  def change
    add_column :course_scores, :created_at, :datetime, :null => false
    add_column :course_scores, :updated_at, :datetime, :null => false
  end
end
