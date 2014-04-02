class CreateOneCourseIntents < ActiveRecord::Migration
  def change
    create_table :one_course_intents do |t|
      t.integer :course_id
      t.integer :user_id
      t.timestamps
    end
  end
end
