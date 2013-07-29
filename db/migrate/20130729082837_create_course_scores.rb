class CreateCourseScores < ActiveRecord::Migration
  def up
    create_table :course_scores do |t|
      t.integer :course_id
      t.integer :student_user_id
      t.string  :score
    end
  end
end
